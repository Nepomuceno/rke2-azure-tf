#!/bin/bash
set -e
DIRECTORY=$(dirname $0)

which kubectl > /dev/null || { echo -e "💥 Error! Command kubectl not installed"; exit 1; }
kubectl version > /dev/null 2>&1 || { echo -e "💥 Error! kubectl is not pointing at a cluster, configure KUBECONFIG or $HOME/.kube/config"; exit 1; }

NODE_THRESHOLD=3

echo "💠 Checking nodes..."
for i in {1..12}; do
  readyNodes=$(kubectl get nodes | grep Ready | wc -l)
  if (( "$readyNodes" >= $NODE_THRESHOLD )); then
    echo "✅ Cluster has $readyNodes nodes ready"
    break
  fi
  echo "⏰ waiting 10 seconds for at least $NODE_THRESHOLD nodes to be ready..."
  sleep 10
done

echo "🚀 Creating smoke test resources..."

kubectl apply -f ${DIRECTORY}/load-balancer.yaml > /dev/null
kubectl apply -f ${DIRECTORY}/pvc-pod.yaml > /dev/null

echo "🔍 Polling resources..."

for i in {1..12}; do
  externalIp=$(kubectl get service/test-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [[ "$externalIp" != "" ]]; then
    echo "✅ SERVICE: test-svc has external IP '$externalIp'"
    break
  fi
  echo "⏰ waiting 10 seconds for load-balancer to be ready..."
  sleep 10
done

for i in {1..12}; do
  pvcStatus=$(kubectl get pvc test-pvc-azure-disk | grep test-pvc-azure-disk | awk '{print $2}')
  if [[ "$pvcStatus" == "Bound" ]]; then
    echo "✅ PVC: test-pvc-azure-disk is 'Bound'"
    break
  fi
  echo "⏰ waiting 10 seconds for test-pvc-azure-disk to be bound..."
  sleep 10
done

for i in {1..12}; do
  podStatus=$(kubectl get po test-pod | grep test-pod | awk '{print $3}')
  if [[ "$podStatus" == "Running" ]]; then
    echo "✅ POD: test-pod is 'Running'"
    break
  fi
  echo "⏰ waiting 10 seconds for test-pod to start..."
  sleep 10
done

echo "❌ Removing smoke test resources..."
kubectl delete -f ${DIRECTORY}/load-balancer.yaml --wait=false
kubectl delete -f ${DIRECTORY}/pvc-pod.yaml --wait=false
kubectl delete pvc test-pvc-azure-disk --wait=false