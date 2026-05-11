#!/bin/bash
# Setup script for level 50 - Chaos Finale
# Taints a node and sets up the chaos scenario

set -e

NAMESPACE=${1:-k8squest}
echo "🔧 Setting up Chaos Finale level..."

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

# Label the node for affinity
echo "🏷️  Labeling node $NODE_NAME with accelerator=gpu..."
kubectl label node "$NODE_NAME" accelerator=gpu --overwrite

# Verify the setup
echo "✅ Node taints:"
kubectl get node "$NODE_NAME" -o jsonpath='{.spec.taints}'
echo ""

echo ""
echo "✅ Node labels:"
kubectl get node "$NODE_NAME" --show-labels

echo ""
echo "✅ Setup complete! Chaos scenario is ready."
