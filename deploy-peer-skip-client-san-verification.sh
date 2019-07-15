#!/bin/bash

kubectl apply -f manifests/secrets.yaml

kubectl apply -f manifests/svc-etcd1.yaml
kubectl apply -f manifests/svc-etcd2.yaml
kubectl apply -f manifests/svc-etcd3.yaml

kubectl apply -f manifests/pod-etcd1-skip.yaml
kubectl apply -f manifests/pod-etcd2-skip.yaml
kubectl apply -f manifests/pod-etcd3-skip.yaml
