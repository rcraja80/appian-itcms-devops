#!/bin/bash
# ============================================================
# ITCMS - Local Security Scan Runner
# Author : Raja (Rajasegaran C) - Cloud & DevOps Engineer
# Usage  : bash azure-devops/security/run_security_scan.sh
# ============================================================

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPORT_DIR="${REPO_ROOT}/security-reports"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

echo "================================================"
echo "  ITCMS Security Scan - ${TIMESTAMP}"
echo "  Author: Rajasegaran C"
echo "================================================"

mkdir -p "${REPORT_DIR}"

# ---- SCAN 1: Checkov - Terraform IaC ----
echo ""
echo "🔍 [1/2] Running Checkov - Terraform IaC Security Scan..."
echo "-----------------------------------------------------------"
checkov \
  --directory "${REPO_ROOT}/terraform" \
  --config-file "${REPO_ROOT}/azure-devops/security/.checkov.yml" \
  --output cli \
  --output json \
  --output-file-path "${REPORT_DIR}" \
  --soft-fail \
  2>&1 | tee "${REPORT_DIR}/checkov_${TIMESTAMP}.txt"

echo "✅ Checkov scan complete → ${REPORT_DIR}/checkov_${TIMESTAMP}.txt"

# ---- SCAN 2: Bandit - Python Code ----
echo ""
echo "🔍 [2/2] Running Bandit - Python Security Scan..."
echo "-----------------------------------------------------------"
bandit \
  -r "${REPO_ROOT}/python-scripts" \
  -c "${REPO_ROOT}/azure-devops/security/.bandit.yml" \
  -f txt \
  -o "${REPORT_DIR}/bandit_${TIMESTAMP}.txt" \
  --severity-level medium \
  2>&1 || true

echo "✅ Bandit scan complete → ${REPORT_DIR}/bandit_${TIMESTAMP}.txt"

# ---- Summary ----
echo ""
echo "================================================"
echo "  ✅ Security Scan Complete"
echo "  Reports saved to: ${REPORT_DIR}/"
echo "  Checkov : checkov_${TIMESTAMP}.txt"
echo "  Bandit  : bandit_${TIMESTAMP}.txt"
echo "================================================"
