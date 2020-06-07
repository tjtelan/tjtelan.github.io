+++
title = "Istio Ingress Traffic Management with Gateways"
date = 2018-08-26
draft = true
[taxonomies]
tags = ["kubernetes", "istio", "ingress", "non-cloud", "servicemesh", "helm"]
+++

## Intended Audience
The intended audience of this post are those who know about Istio, and the concept of Service Mesh, and want to try it out in their own private lab.

If you don't know about Istio, or Service Mesh, then read up on Istio's interpretation of service mesh, and how they aim to solve it. https://istio.io/docs/concepts/what-is-istio/

In this post, I will walk through installing Istio 1.0 on Kubernetes using Helm. Then setting up https/443 ingress traffic without a load balancer.

---

### Not covered
* Deploying VMs
* Installing Docker and Kubernetes (Suggestion: Kubespray)
* LetsEncrypt integration for TLS certificates

### Requirements
* A Kubernetes cluster with ports 80, 443 not exposed
* helm
* [istio release](https://istio.io/docs/setup/kubernetes/download-release/)

## Install Istio

### Step 1: Install Helm chart from Istio release

This is an example Helm installation from the Istio release for a [minimum traffic management configuration](https://istio.io/docs/setup/kubernetes/helm-install/#customization-example-traffic-management-minimal-set) -- except with `--set sidecarInjectorWebhook.enabled=false` removed, because I actually want sidecar webhooks enabled.
```
helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
  --set ingress.enabled=false \
  --set gateways.istio-ingressgateway.enabled=false \
  --set gateways.istio-egressgateway.enabled=false \
  --set galley.enabled=false \
  --set mixer.enabled=false \
  --set prometheus.enabled=false \
  --set global.proxy.envoyStatsd.enabled=false
```

### Step 2: Install Istio Ingress Gateway as a DaemonSet

The helm chart installs the Istio ingressgateway in a manner that requires a cloud load balancer or using NodePort (by default using http/31380, https/31390). We want to be able to use port 80 and 443, which we can only do with a DaemonSet's `hostPort`.

(Figure out cleaner instructions, bc I went a roundabout way, by using `helm template` to generate the istio-ingresgateway Deployment, then converting it into a DaemonSet. This doesn't include the expected configmaps)

#### If you want to use HTTPS

You need to install your tls certificate as a secret in the `istio-system` with the name `istio-ingressgateway-certs`.

```
kubectl create secret tls istio-ingressgateway-certs -n istio-system --cert=/path/to/fullchain.pem --key=/path/to/privkey.pem
```

### Step 3: Deploy your service, gateway and virtualservice
