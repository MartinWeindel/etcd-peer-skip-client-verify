# Test environment to demonstrate etcd peer client address check problem

On initialising the peer-to-peer communication, ETCD checks the CN/SAN for the client side. This is not feasible, if the client IP address (of the HTTPS connection) is not stable or unknown at the time of creation of the certificate.

This project provides a test environment to demonstrate the problem.
For this purpose, a cluster of three ETCD servers is installed in Kubernetes. The servers are made available as K8s services, i.e.
the ClusterIP address of their services. This is a simulation of a realistic setup, e.g. the ETCD are running in different Kubernetes clusters and see each other only through the load balanced service.
In this test setup, it shows the same characteristics: the IP address of the ETCD server (pod IP) is different from the IP address seen by the peer members.

## Prerequistes

For installation you need a Kubernetes cluster, e.g. using Docker and [kind](https://kind.sigs.k8s.io/docs/user/quick-start)

## Deploy with `--peer-skip-client-san-verification` flag

For this purpose, we use an own image containing the ETCD pull request [#10524](https://github.com/etcd-io/etcd/pull/10524/):

1. Start a Kubernetes cluster with kind (or setup an environment with Kubernetes yourself)

    ```bash 
    kind create cluster
    export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
    kubectl cluster-info
    ```

2. Deploy certificates, pods and services with

    ```bash 
    ./deploy-peer-skip-client-san-verification.sh
    ```

    To view the command line for starting ETCD, see pod specification at [manifest/pod-etcd1-skip.yaml](./manifests/pod-etcd1-skip.yaml)

3. Show logs of an ETCD server to verify successful startup

    ```bash
    kubectl logs etcd3
    ```

    A typical log output will look like [./logs_pod_etcd3_deploy-peer-skip-client-san-verification.txt](./logs_pod_etcd3_deploy-peer-skip-client-san-verification.txt)

4. Cleanup with

    ```bash
    ./cleanup.sh
    kind delete cluster
    ```

## Deploy without skip flag

Same as above, but in step 2 use

```bash 
./deploy-noskip.sh
```

See pod specification at [manifest/pod-etcd1-noskip.yaml](./manifests/pod-etcd1-noskip.yaml)

The typical log output (see [./logs_pod_etcd3_deploy-noskip.txt](./logs_pod_etcd3_deploy-noskip.txt)) shows problems like

```txt
...
2019-07-15 08:54:29.019527 I | etcdserver/membership: added member 6a2edc9bc157d038 [https://etcd2.default.svc.cluster.local:2380] to cluster 3c583179ce9a9924
2019-07-15 08:54:29.019738 I | etcdserver/membership: added member 79a5da4dbaad6721 [https://etcd3.default.svc.cluster.local:2380] to cluster 3c583179ce9a9924
2019-07-15 08:54:29.020034 I | etcdserver/membership: added member a75ec0ab922917e2 [https://etcd1.default.svc.cluster.local:2380] to cluster 3c583179ce9a9924
2019-07-15 08:54:29.127997 I | embed: rejected peer connection from "10.32.0.4:44336" (error "tls: \"10.32.0.4\" does not match any of DNSNames [\"localhost\" \"etcd1.default.svc.cluster.local\" \"etcd2.default.svc.cluster.local\" \"etcd3.default.svc.cluster.local\"]", ServerName "etcd3.default.svc.cluster.local", IPAddresses [], DNSNames ["localhost" "etcd1.default.svc.cluster.local" "etcd2.default.svc.cluster.local" "etcd3.default.svc.cluster.local"])
...
```