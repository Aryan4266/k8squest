#!/bin/bash
set -e

echo "🎮 K8sQuest Installation"
echo "========================"
echo ""

# Check prerequisites
command -v kind >/dev/null || { echo "❌ kind not found. Install with: brew install kind"; exit 1; }
command -v kubectl >/dev/null || { echo "❌ kubectl not found. Install with: brew install kubectl"; exit 1; }
command -v python3 >/dev/null || { echo "❌ python3 not found"; exit 1; }

# Verify Python version >= 3.9
PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PYTHON_MAJOR=$(python3 -c "import sys; print(sys.version_info.major)")
PYTHON_MINOR=$(python3 -c "import sys; print(sys.version_info.minor)")
if [ "$PYTHON_MAJOR" -lt 3 ] || { [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 9 ]; }; then
  echo "❌ Python 3.9+ required, but found $PYTHON_VERSION"
  echo "   Install a newer Python:"
  echo "     macOS:  brew install python@3.11"
  echo "     Linux:  sudo apt install python3.11"
  echo "   Then set it as default or update the PATH so 'python3' resolves to 3.9+"
  exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
  echo "🐍 Creating Python virtual environment..."
  python3 -m venv venv
  if [ ! -d "venv" ]; then
    echo "❌ Failed to create virtual environment"
    exit 1
  fi
fi

# Activate virtual environment and install dependencies
echo "📦 Installing Python dependencies..."
if [ -f "venv/bin/activate" ]; then
  source venv/bin/activate
elif [ -f "venv/Scripts/activate" ]; then
  source venv/Scripts/activate
else
  echo "❌ Virtual environment activation script not found"
  echo "Expected: venv/bin/activate or venv/Scripts/activate"
  exit 1
fi
pip install -q -r requirements.txt

echo "✅ Python packages installed"
echo ""

# Create Kubernetes cluster
if ! kind get clusters | grep k8squest >/dev/null 2>&1; then
  echo "🔧 Creating Kubernetes cluster..."
  kind create cluster --name k8squest
else
  echo "✅ Cluster already exists"
fi

kubectl config use-context kind-k8squest

# Create k8squest namespace
echo "🏗️  Setting up k8squest namespace..."
kubectl create namespace k8squest --dry-run=client -o yaml | kubectl apply -f -

# Setup RBAC for safety
echo "🛡️  Configuring safety guards (RBAC)..."
if [ -f "rbac/k8squest-rbac.yaml" ]; then
  kubectl apply -f rbac/k8squest-rbac.yaml
  echo "✅ Safety guards configured"
else
  echo "⚠️  Warning: RBAC config not found, skipping"
fi

echo ""
echo "🚀 Setup Complete!"
echo ""
echo "To start playing, use the shortcut:"
echo "  ./play.sh"
echo ""
