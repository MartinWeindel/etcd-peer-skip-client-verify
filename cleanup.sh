#!/bin/bash

kubectl delete pods etcd1 etcd2 etcd3
kubectl delete svc etcd1 etcd2 etcd3
kubectl delete secrets etcd-client etcd-peer etcd-server
