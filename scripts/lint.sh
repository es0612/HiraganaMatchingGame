#!/usr/bin/env bash
set -euo pipefail

MODE="lint"
if [[ "${1:-}" == "--fix" ]]; then
  MODE="fix"
fi

has() { command -v "$1" >/dev/null 2>&1; }

if ! has swiftformat; then
  echo "[warn] swiftformat が見つかりません。brew install swiftformat を実行してください。" >&2
else
  if [[ "$MODE" == "fix" ]]; then
    echo "[info] SwiftFormat を適用中..."
    swiftformat .
  else
    echo "[info] SwiftFormat をチェック中..."
    swiftformat --lint . || true
  fi
fi

if ! has swiftlint; then
  echo "[warn] swiftlint が見つかりません。brew install swiftlint を実行してください。" >&2
else
  echo "[info] SwiftLint を実行中..."
  swiftlint || true
fi

