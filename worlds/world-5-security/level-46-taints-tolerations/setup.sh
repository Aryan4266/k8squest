#!/bin/bash
# Setup script for level 46 - Taints and Tolerations
# Taints a node with dedicated=gpu:NoSchedule

set -e

NAMESPACE=${1:-k8squest}
echo "🔧 Setting up Taints and Tolerations level..."

# Get the first node (works for both kind and k3s)
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

if [ -z "$NODE_NAME" ]; then
    echo "❌ No nodes found in the cluster"
    exit 1
fi

echo "📍 Found node: $NODE_NAME"

# Taint the node to simulate dedicated GPU node
echo "🚧 Tainting node $NODE_NAME with dedicated=gpu:NoSchedule..."
kubectl taint nodes "$NODE_NAME" dedicated=gpu:NoSchedule --overwrite

# Verify the taint
echo "✅ Node taints:"
kubectl get node "$NODE_NAME" -o jsonpath='{.spec.taints}'
echo ""

echo ""
echo "✅ Setup complete! Node is tainted - pods need tolerations to schedule."
