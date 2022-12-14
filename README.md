# Ubuntu 20.04 SSH server

## How to run using Docker

With a randomly generated password:

```
docker run -p 2222:22 samdecrock/sshserver:1.0.0:1.0.0
```

With a specified password:
```
docker run -p 2222:22 --env ROOT_PASSWORD=mysecret samdecrock/sshserver:1.0.0:1.0.0
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
spec:
  hostname: sshserver
  containers:
    - name: sshserver
      image: samdecrock/sshserver:1.0.0
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


