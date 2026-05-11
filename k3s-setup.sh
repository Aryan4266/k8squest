#!/bin/bash
# Setup k3s to be compatible with K8sQuest levels
# This script creates the expected storage classes and configurations

set -e

echo "🔧 Setting up k3s for K8sQuest compatibility..."

# Check if k3s is running
if ! systemctl is-active --quiet k3s; then
    echo "❌ k3s is not running. Please start k3s first."
    exit 1
fi

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Create 'standard' storage class to match kind's default
echo "📦 Creating 'standard' storage class..."
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
EOF

# Create 'fast' storage class for levels that need it
echo "📦 Creating 'fast' storage class..."
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
EOF

# Create 'premium-ssd' storage class
echo "📦 Creating 'premium-ssd' storage class..."
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: premium-ssd
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
EOF

# Make 'local-path' non-default and 'standard' the default
echo "🔧 Setting 'standard' as default storage class..."
kubectl annotate sc local-path storageclass.kubernetes.io/is-default-class-
kubectl annotate sc standard storageclass.kubernetes.io/is-default-class=true

# Verify setup
echo ""
echo "✅ k3s setup complete! Storage classes available:"
kubectl get storageclass

echo ""
echo "📊 Node information:"
kubectl get nodes -o wide

echo ""
echo "✅ k3s is now compatible with K8sQuest levels!"
