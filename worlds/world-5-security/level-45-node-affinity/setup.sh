#!/bin/bash
# Setup script for level 45 - Node Affinity
# Labels a node with accelerator=gpu for the affinity rule

set -e

NAMESPACE=${1:-k8squest}
echo "🔧 Setting up Node Affinity level..."

# Get the first node (works for both kind and k3s)
NODE_NAME=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

if [ -z "$NODE_NAME" ]; then
    echo "❌ No nodes found in the cluster"
    exit 1
fi

echo "📍 Found node: $NODE_NAME"

# Label the node for GPU workload affinity
echo "🏷️  Labeling node $NODE_NAME with accelerator=gpu..."
kubectl label node "$NODE_NAME" accelerator=gpu --overwrite

# Verify the label
echo "✅ Node labels:"
kubectl get node "$NODE_NAME" --show-labels

echo ""
echo "✅ Setup complete! Node is ready for GPU workload scheduling."
