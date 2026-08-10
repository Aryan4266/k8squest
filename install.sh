```bash
#!/bin/bash

set -euo pipefail

echo "🎮 K8sQuest Installation"
echo "========================"
echo ""

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

NAMESPACE="k8squest"
REQUIREMENTS_FILE="requirements.txt"
VENV_DIR="venv"

# ------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------

error() {
    echo "❌ $1"
    exit 1
}

success() {
    echo "✅ $1"
}

warning() {
    echo "⚠️  $1"
}

info() {
    echo "ℹ️  $1"
}

# ------------------------------------------------------------
# Check prerequisites
# ------------------------------------------------------------

echo "🔍 Checking prerequisites..."
echo ""

# kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    error "kubectl not found.

Install kubectl and make sure it is available in PATH."
fi

success "kubectl detected"

# Python
if ! command -v python3 >/dev/null 2>&1; then
    error "Python 3 not found.

Install Python 3.9+ using your operating system package manager."
fi

# ------------------------------------------------------------
# Check Python version
# ------------------------------------------------------------

PYTHON_VERSION=$(python3 -c '
import sys
v = sys.version_info
print(f"{v.major}.{v.minor}")
if (v.major, v.minor) < (3, 9):
    sys.exit(1)
') || {
    error "Python 3.9+ required.

Detected Python version: ${PYTHON_VERSION:-unknown}"
}

success "Python $PYTHON_VERSION detected"

# ------------------------------------------------------------
# Check kubectl configuration
# ------------------------------------------------------------

echo ""
echo "☸️  Checking Kubernetes cluster..."
echo ""

if ! kubectl version --request-timeout=10s >/dev/null 2>&1; then
    error "Unable to connect to Kubernetes.

Make sure:
  1. A Kubernetes cluster is running
  2. kubectl is installed
  3. Your kubeconfig is configured
  4. kubectl can access the cluster

Try:
  kubectl get nodes"
fi

success "Kubernetes API is reachable"

# ------------------------------------------------------------
# Display cluster information
# ------------------------------------------------------------

echo ""
echo "📡 Kubernetes cluster:"
echo ""

kubectl cluster-info

echo ""
echo "🖥️  Kubernetes nodes:"
kubectl get nodes -o wide

# ------------------------------------------------------------
# Check node readiness
# ------------------------------------------------------------

echo ""
echo "🔎 Checking node readiness..."

NOT_READY_NODES=$(kubectl get nodes \
    --no-headers \
    | awk '$2 != "Ready" {print $1}')

if [ -n "$NOT_READY_NODES" ]; then
    warning "The following nodes are not Ready:"
    echo "$NOT_READY_NODES"
    echo ""
    warning "K8sQuest installation will continue, but workloads may not start."
else
    success "All Kubernetes nodes are Ready"
fi

# ------------------------------------------------------------
# Check requirements.txt
# ------------------------------------------------------------

echo ""

if [ ! -f "$REQUIREMENTS_FILE" ]; then
    error "$REQUIREMENTS_FILE not found.

Run this script from the K8sQuest project root."
fi

success "$REQUIREMENTS_FILE found"

# ------------------------------------------------------------
# Create Python virtual environment
# ------------------------------------------------------------

if [ ! -d "$VENV_DIR" ]; then
    echo ""
    echo "🐍 Creating Python virtual environment..."

    python3 -m venv "$VENV_DIR"

    if [ ! -f "$VENV_DIR/bin/activate" ]; then
        error "Failed to create Python virtual environment."
    fi

    success "Virtual environment created"
else
    success "Python virtual environment already exists"
fi

# ------------------------------------------------------------
# Activate virtual environment
# ------------------------------------------------------------

echo ""
echo "📦 Installing Python dependencies..."

if [ ! -f "$VENV_DIR/bin/activate" ]; then
    error "Virtual environment activation script not found:
$VENV_DIR/bin/activate"
fi

source "$VENV_DIR/bin/activate"

# Upgrade pip
python -m pip install --upgrade pip -q

# Install requirements
python -m pip install -q -r "$REQUIREMENTS_FILE"

success "Python packages installed"

# ------------------------------------------------------------
# Kubernetes namespace
# ------------------------------------------------------------

echo ""
echo "🏗️  Setting up Kubernetes namespace..."

kubectl create namespace "$NAMESPACE" \
    --dry-run=client \
    -o yaml \
    | kubectl apply -f -

success "Namespace '$NAMESPACE' ready"

# ------------------------------------------------------------
# Setup RBAC
# ------------------------------------------------------------

echo ""
echo "🛡️  Configuring K8sQuest RBAC..."

if [ -f "rbac/k8squest-rbac.yaml" ]; then

    kubectl apply -f "rbac/k8squest-rbac.yaml"

    success "RBAC configuration applied"

else

    warning "rbac/k8squest-rbac.yaml not found"
    warning "Skipping RBAC configuration"
fi

# ------------------------------------------------------------
# Verify namespace
# ------------------------------------------------------------

echo ""
echo "🔎 Verifying Kubernetes setup..."

if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    success "Namespace '$NAMESPACE' is available"
else
    error "Failed to create namespace '$NAMESPACE'"
fi

# ------------------------------------------------------------
# Final output
# ------------------------------------------------------------

echo ""
echo "======================================"
echo "🚀 K8sQuest Setup Complete!"
echo "======================================"
echo ""

echo "☸️  Kubernetes Context:"
kubectl config current-context

echo ""
echo "📦 Namespace:"
echo "   $NAMESPACE"

echo ""
echo "🎮 To start playing:"
echo "   ./play.sh"

echo ""
echo "🔍 Useful commands:"
echo ""
echo "   kubectl get nodes"
echo "   kubectl get pods -n $NAMESPACE"
echo "   kubectl get all -n $NAMESPACE"
echo ""

echo "Have fun learning Kubernetes! 🎮☸️"
```
