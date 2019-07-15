# Test environment to demonstrate etcd peer client address check problem

On initialising the peer-to-peer communication, ETCD checks the CN/SAN for the client side. This is not feasible, if the client IP address (of the HTTPS connection) is not stable or unknown at the time of creation of the certificate.

This project provides a test environment to demonstrate the problem.
For this purpose, three ETCD servers are installed in Kubernetes and made available as K8s services.
Each ETCD server is running in a K8s pod and is made visible to the other ETCD servers via their
service IP address. Althought this setup is not our production setup, it shows the same characteristics: The ETCD servers are running in different networks with NAT translation.

## Prerequistes

For installation you need a Kubernetes cluster, e.g. using Docker and [kind](https://kind.sigs.k8s.io/docs/user/quick-start)

## Deploy with `--peer-skip-client-san-verification` flag

For this purpose, we use an own image containing the ETCD pull request [#10524](https://github.com/etcd-io/etcd/pull/10524/):

1. Start a Kubernetes cluster with kind (optional)

    ```bash 
    kind create cluster
    export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
    kubectl cluster-info
    ```

2. Deploy certificates, pods and services with

    ```bash 
    ./deploy-peer-skip-client-san-verification.sh
    ```

    This starts ETCD with following command line

    ```
    
    ```

3. Show logs of an ETCD server to verify successful startup

    ```bash
    kubectl logs etcd3
    ```

    See checked in log output [./logs_pod_etcd3_deploy-peer-skip-client-san-verification.txt](./logs_pod_etcd3_deploy-peer-skip-client-san-verification.txt) for typical output

4. Cleanup with

    ```bash
    ./cleanup.sh
    kind delete cluster
    ```

## Deploy standard ETCD without skip

Same as above, but in step 2 use

```bash 
./deploy-noskip.sh
```

The only effective difference is the missing `--peer-skip-client-verify=true` option on starting ETCD.

See checked in log output [./logs_pod_etcd3_deploy-noskip.txt](./logs_pod_etcd3_deploy-noskip.txt) for typical output with showing problems like

```txt
...
2019-07-15 08:54:29.019527 I | etcdserver/membership: added member 6a2edc9bc157d038 [https://etcd2.default.svc.cluster.local:2380] to cluster 3c583179ce9a9924
2019-07-15 08:54:29.019738 I | etcdserver/membership: added member 79a5da4dbaad6721 [https://etcd3.default.svc.cluster.local:2380] to cluster 3c583179ce9a9924
2019-07-15 08:54:29.020034 I | etcdserver/membership: added member a75ec0ab922917e2 [https://etcd1.default.svc.cluster.local:2380] to cluster 3c583179ce9a9924
2019-07-15 08:54:29.127997 I | embed: rejected peer connection from "10.32.0.4:44336" (error "tls: \"10.32.0.4\" does not match any of DNSNames [\"localhost\" \"etcd1.default.svc.cluster.local\" \"etcd2.default.svc.cluster.local\" \"etcd3.default.svc.cluster.local\"]", ServerName "etcd3.default.svc.cluster.local", IPAddresses [], DNSNames ["localhost" "etcd1.default.svc.cluster.local" "etcd2.default.svc.cluster.local" "etcd3.default.svc.cluster.local"])
...
```