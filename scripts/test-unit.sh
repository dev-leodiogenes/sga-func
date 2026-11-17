#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "====================================="
echo " SGA-Func - Testes Unitarios"
echo "====================================="

runghc \
    -XOverloadedStrings \
    -XOverloadedRecordDot \
    -XDuplicateRecordFields \
    -XImplicitParams \
    -XOverloadedLabels \
    -i. \
    -ibuild \
    Test/Spec.hs

echo "Testes concluidos com sucesso!"
