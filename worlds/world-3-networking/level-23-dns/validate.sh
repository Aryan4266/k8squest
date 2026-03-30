#!/bin/bash

# Check if client pod can resolve service DNS
LOGS=$(kubectl logs app-client -n k8squest --tail=10 2>/dev/null)

# Check for pg_isready success message with correct service name
if echo "$LOGS" | grep -q "accepting connections"; then
  echo "✅ Level complete! DNS resolution working"
  echo "   Client successfully connected to database-service"
  exit 0
else
  echo "❌ DNS resolution failing. Check the service name in client pod"
  echo "Hint: Service is named 'database-service', not 'database'"
  echo ""
  echo "Recent logs:"
  echo "$LOGS"
  exit 1
fi
