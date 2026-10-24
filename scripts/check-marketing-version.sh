#!/usr/bin/env bash
# MARKETING_VERSION が「最新の v* タグ」と「App Store の公開中バージョン」のどちらよりも大きいかを確かめる（#55）。
# 承認済みのバージョンのまま app/ の変更をマージすると、Xcode Cloud のビルドが ITMS-90186 / 90062 で却下される（#52）。
#
# 使い方: scripts/check-marketing-version.sh [path/to/project.pbxproj]
#   タグは取得済みのものをすべて見る（CI では actions/checkout に fetch-depth: 0 が必要）。
#   タグ付けが遅れても検出できるように、iTunes Lookup の公開中バージョンとも比べる。
#   Lookup に失敗したとき・0 件のときは警告を出してタグだけで判定する。
#   LOOKUP_URL を設定すると Lookup の URL を差し替えられる（テスト用）。
set -euo pipefail

PBXPROJ="${1:-app/HiraganaMatchingGame.xcodeproj/project.pbxproj}"
LOOKUP_URL="${LOOKUP_URL:-https://itunes.apple.com/lookup?bundleId=com.asapapalab.HiraganaMatchingGame&country=jp}"

# 全ターゲット・全構成で同じ値になっているか（置換漏れの検出）
VERSIONS=$(grep -E 'MARKETING_VERSION = ' "$PBXPROJ" | sed -E 's/.*= ([0-9.]+);.*/\1/' | sort -u)
if [ -z "$VERSIONS" ]; then
    echo "::error::$PBXPROJ に MARKETING_VERSION が見つかりません"
    exit 1
fi
if [ "$(echo "$VERSIONS" | wc -l | tr -d ' ')" != "1" ]; then
    echo "::error::MARKETING_VERSION がターゲット間で揃っていません: $(echo "$VERSIONS" | tr '\n' ' ')"
    exit 1
fi
CURRENT="$VERSIONS"
if ! echo "$CURRENT" | grep -qE '^[0-9]+(\.[0-9]+)*$'; then
    echo "::error::MARKETING_VERSION を数字の形（例: 1.0.3）として解釈できません: $CURRENT"
    exit 1
fi

# v1.0.3-rc1 のようなタグは sort -V の順序がずれるので、vX.Y.Z の形だけを見る
LAST_TAG=$(git tag --list 'v*' --sort=-v:refname | grep -E '^v[0-9]+(\.[0-9]+)*$' | head -1 | sed 's/^v//' || true)
STORE=$(curl -fsSL --max-time 20 "$LOOKUP_URL" 2>/dev/null \
    | python3 -c 'import json,sys; r=json.load(sys.stdin).get("results") or []; print(r[0]["version"] if r else "")' 2>/dev/null \
    || true)

echo "MARKETING_VERSION: $CURRENT"
echo "最新の v* タグ: ${LAST_TAG:-（なし）}"
if [ -n "$STORE" ]; then
    echo "App Store の公開中バージョン: $STORE"
else
    echo "::warning::iTunes Lookup から公開中バージョンを取得できませんでした。タグだけで判定します"
fi

for BASE in "$LAST_TAG" "$STORE"; do
    [ -z "$BASE" ] && continue
    HIGHEST=$(printf '%s\n%s\n' "$BASE" "$CURRENT" | sort -V | tail -1)
    # 同じ値のとき sort -V は CURRENT を返すので、同値は別に判定する
    if [ "$CURRENT" = "$BASE" ] || [ "$HIGHEST" != "$CURRENT" ]; then
        echo "::error::MARKETING_VERSION ($CURRENT) が $BASE より大きくありません。次のパッチに上げてください（CLAUDE.md「進め方」、#52）"
        exit 1
    fi
done

echo "✅ MARKETING_VERSION ($CURRENT) は既存のリリースより大きい値です"
