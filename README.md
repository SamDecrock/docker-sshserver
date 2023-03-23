# Ubuntu 20.04 SSH server in a docker container


## Environment variables

* `ROOT_PASSWORD`: Sets the root password. If omitted, a password will be generated.
* `GATEWAY_PORTS`: Sets SSH's `GatewayPorts` to a specified value.
* `PASSWORD_AUTHENTICATION`: Sets  SSH's `PasswordAuthentication` to a specified value.

## How to run using Docker

With a randomly generated password:

```
docker run -p 2222:22 samdecrock/sshserver:1.0.1
```

With a specified password:
```
docker run -p 2222:22 --env ROOT_PASSWORD=mysecret samdecrock/sshserver:1.0.1
```

Enabling `GatewayPorts`:
```
docker run -p 3333:22 -e GATEWAY_PORTS=yes samdecrock/sshserver:1.0.1
```

The ssh server is now available on port 2222:
```
ssh root@localhost -p 2222
```

## How to run it in Kubernetes

The beauty of this container is that you can run it in Kubernetes. I use this trick a lot to backup the content of my PVCs. You can read more about this in my article on medium.com: https://samdecrock.medium.com/transferring-data-between-kubernetes-clusters-c0c1b59930d1

Create a `sshserver.yaml` with:


```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: sshserver
  labels:
    name: sshserver
spec:
  hostname: sshserver
  containers:
    - name: sshserver
      image: samdecrock/sshserver:1.0.1
      ports:
        - containerPort: 22
      volumeMounts:
        - name: data1
          mountPath: /mounts/data1
        - name: data2
          mountPath: /mounts/data2
  volumes:
    - name: data1
      persistentVolumeClaim:
        claimName: data1
    - name: data2
      persistentVolumeClaim:
        claimName: data2

---
apiVersion: v1
kind: Service
metadata:
  name: sshserver
spec:
  ports:
    - name: ssh
      protocol: TCP
      port: 22
      targetPort: 22
  selector:
    name: sshserver
  type: LoadBalancer
```

Apply it to a namespace with:

	kubectl -n <namespace> apply -f sshserver.yaml

By using a service of type LoadBalancer, we expose the ssh server using an external IP address.

Find the external IP address with:

	kubectl -n <namespace> get services sshserver

Connect to that IP address with:

	ssh root@<external-ip-address>

## Run on Kubernetes with SSH public key authentication only

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sshserver-cm
data:
  authorized_keys: |
    ssh-rsa <your public key>

---
apiVersion: v1
kind: Pod
metadata:
  name: sshserver
  labels:
    name: sshserver
spec:
  hostname: sshserver
  containers:
    - name: sshserver
      image: samdecrock/sshserver:1.0.1
      env:
        - name: PASSWORD_AUTHENTICATION
          value: "no"
      ports:
        - containerPort: 22
      volumeMounts:
        - name: sshserver-cm
          mountPath: /root/.ssh/authorized_keys
          subPath: authorized_keys
  volumes:
    - name: sshserver-cm
      configMap:
        name: sshserver-cm
        defaultMode: 0644

---
apiVersion: v1
kind: Service
metadata:
  name: sshserver
spec:
  ports:
    - name: ssh
      protocol: TCP
      port: 22
      targetPort: 22
  selector:
    name: sshserver
  type: LoadBalancer
```
