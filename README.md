# 🚀 Kubernetes Part 2 -- Advanced Concepts (EKS Activity)

This repository contains the hands-on work for **Kubernetes Part 2**,
focusing on advanced Kubernetes concepts deployed on a custom-built
**Amazon EKS cluster**.\
The activity includes:

-   Namespace creation\
-   ConfigMaps & Secrets\
-   Deployments\
-   LoadBalancer, ClusterIP, and NodePort Services\
-   Testing and verification

------------------------------------------------------------------------

## 🏗️ **1. EKS Cluster Setup (Terraform)**

The EKS cluster `shared-eks-cluster` was provisioned using Terraform:

-   EKS version: **1.30**
-   2 managed node groups (t3.medium)
-   Custom VPC (private + public subnets)
-   Public API endpoint enabled for kubectl access
-   IAM admin permissions enabled for cluster creator

### Deploy EKS Cluster

``` sh
terraform init
terraform apply -auto-approve
```

Update kubeconfig:

``` sh
aws eks update-kubeconfig --region ap-southeast-1 --name shared-eks-cluster
kubectl get nodes
```

------------------------------------------------------------------------

## 📁 **2. Namespace Creation**

Namespace created for isolation:

``` sh
kubectl create namespace <your-name>-eks-activity
kubectl get namespaces
```

------------------------------------------------------------------------

## ⚙️ **3. ConfigMap & Secret**

### Create ConfigMap

Stores non-sensitive configuration values:

``` sh
kubectl create configmap sample-config   --from-literal=welcome-message="Welcome to the EKS Activity"   -n <your-namespace>
```

### Create Secret

Stores sensitive configuration:

``` sh
kubectl create secret generic sample-secret   --from-literal=password='mysecurepassword'   -n <your-namespace>
```

------------------------------------------------------------------------

## 🐳 **4. Deployment**

A simple HTTP Echo application was deployed using both ConfigMap and
Secret values.

### `httpd-deployment.yaml`

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <your-name>-sample-httpd-app
  namespace: <your-namespace>
spec:
  replicas: 2
  selector:
    matchLabels:
      app: httpd-app
  template:
    metadata:
      labels:
        app: httpd-app
    spec:
      containers:
      - name: httpd-app
        image: hashicorp/http-echo:latest
        args:
        - "-text=$(WELCOME_MESSAGE)"
        ports:
        - containerPort: 5678
        env:
        - name: WELCOME_MESSAGE
          valueFrom:
            configMapKeyRef:
              name: sample-config
              key: welcome-message
        - name: APP_PASSWORD
          valueFrom:
            secretKeyRef:
              name: sample-secret
              key: password
```

Apply:

``` sh
kubectl apply -f httpd-deployment.yaml
kubectl get pods -n <your-namespace>
```

------------------------------------------------------------------------

## 🌐 **5. Kubernetes Services**

### 5.1 LoadBalancer Service (External Access)

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: <your-name>-loadbalancer-service
  namespace: <your-namespace>
spec:
  type: LoadBalancer
  selector:
    app: httpd-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5678
```

------------------------------------------------------------------------

### 5.2 ClusterIP Service (Internal Access)

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: <your-name>-clusterip-service
  namespace: <your-namespace>
spec:
  type: ClusterIP
  selector:
    app: httpd-app
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 5678
```

Testing via port forward:

``` sh
kubectl port-forward service/<your-name>-clusterip-service -n <your-namespace> 8080:8080
```

Open: http://localhost:8080

------------------------------------------------------------------------

### 5.3 NodePort Service (Node-Level Access)

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: <your-name>-nodeport-service
  namespace: <your-namespace>
spec:
  type: NodePort
  selector:
    app: httpd-app
  ports:
  - protocol: TCP
    port: 30001
    targetPort: 5678
```

Find NodePort:

``` sh
kubectl get svc -n <your-namespace>
kubectl get nodes -o wide
```

Access:\
`http://<node-ip>:<nodeport>`

------------------------------------------------------------------------

## 🔍 **6. Verification Commands**

### Show Namespace

``` sh
kubectl get namespaces
```

### Show ConfigMap & Secret

``` sh
kubectl get configmap -n <your-namespace>
kubectl get secrets -n <your-namespace>
```

### Show Deployment & Pods

``` sh
kubectl get deployment -n <your-namespace>
kubectl get pods -n <your-namespace>
```

### Show Services

``` sh
kubectl get svc -n <your-namespace>
```

------------------------------------------------------------------------

## ✔️ **7. Summary of Learnings**

-   How ConfigMaps and Secrets inject data into pods\
-   How Deployments manage replica sets and ensure application uptime\
-   Differences between **ClusterIP**, **NodePort**, and
    **LoadBalancer**\
-   How Kubernetes exposes internal vs external traffic\
-   How to operate and test applications deployed onto EKS

------------------------------------------------------------------------
