
## Create EKS Cluster ##

```
CLUSTER_NAME=<<your_cluster_name>>

eksctl create cluster \
--name=${CLUSTER_NAME} \
--managed \
--version 1.18 \
--region=us-east-1 \
--zones=us-east-1a,us-east-1b \
--nodegroup-name minions \
--node-type=t3.medium \
--nodes=2 --nodes-min=1 --nodes-max=20 \
--node-private-networking \
--ssh-access \
--alb-ingress-access \
--appmesh-access \
--asg-access
```

### Configure Cluster Auto Scaler 
1. `kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml`

2. `kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"`

3. `kubectl -n kube-system edit deployment.apps/cluster-autoscaler`

4. Edit the cluster-autoscaler container command to replace 
`<YOUR CLUSTER NAME>` with your cluster's name.

Add the following options.

```
--balance-similar-node-groups
--skip-nodes-with-system-pods=false
```

5. `kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v1.18.3`
6. `kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler`


### Configure ALB Ingress Controller
https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-setup/ 

### Configure Prometheus (using Helm)

```
# add prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# add grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts

kubectl create namespace prometheus

helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

```

### Deploy Grafana

```
mkdir ${HOME}/environment/grafana

cat << EoF > ${HOME}/environment/grafana/grafana.yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus.svc.cluster.local
      access: proxy
      isDefault: true
EoF


kubectl create namespace grafana

helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values ${HOME}/environment/grafana/grafana.yaml \
    --set service.type=LoadBalancer


# Get grafana end point
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# When logging in, use the username admin and get the password hash by running the following:
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

echo "http://$ELB"

```
