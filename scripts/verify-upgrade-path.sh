#!/usr/bin/env bash
# v1.0.1 相当の UserDefaults（StarUnlock_* 旧キー）を持つ端末を模して最新ビルドを起動し、
# 起動後も旧キーが残っていることを確認する（#18 のアップグレード経路テスト）。
#
# 使い方: scripts/verify-upgrade-path.sh <simulator UDID> [path/to/HiraganaMatchingGame.app]
#   .app を省略すると DerivedData の最新 Debug-iphonesimulator ビルドを使う。
#
# 注意: `xcrun simctl spawn <udid> defaults write` はシミュレータ全体の Preferences に書き込み、
#       アプリのコンテナ内 plist には反映されない。必ずコンテナ内の plist を直接書く。
set -euo pipefail

UDID="${1:?simulator UDID を指定してください (xcrun simctl list devices available)}"
BID="com.asapapalab.HiraganaMatchingGame"
APP="${2:-$(ls -td "$HOME"/Library/Developer/Xcode/DerivedData/HiraganaMatchingGame-*/Build/Products/Debug-iphonesimulator/HiraganaMatchingGame.app | head -1)}"
WAIT_SECONDS="${WAIT_SECONDS:-12}"

echo "app: $APP"
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl terminate "$UDID" "$BID" >/dev/null 2>&1 || true
xcrun simctl uninstall "$UDID" "$BID" >/dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP"

CONTAINER="$(xcrun simctl get_app_container "$UDID" "$BID" data)"
PLIST="$CONTAINER/Library/Preferences/$BID.plist"
mkdir -p "$(dirname "$PLIST")"
python3 - "$PLIST" <<'PY'
import plistlib, sys
legacy = {
    "StarUnlock_UnlockedCharacters": ["あ", "い", "う", "え", "お", "か", "き"],
    "StarUnlock_Achievements": ["firstCompletion", "perfectScore"],
    "StarUnlock_LevelStars": {"1": 3, "2": 2},
    "StarUnlock_TotalTimePlayed": 120.5,
    "StarUnlock_CurrentStreak": 5,
    "StarUnlock_HighestStreak": 8,
    "LevelProgression_TotalStars": 6,
}
plistlib.dump(legacy, open(sys.argv[1], "wb"))
PY
echo "seeded legacy keys into container plist"

xcrun simctl launch "$UDID" "$BID" >/dev/null
sleep "$WAIT_SECONDS"
xcrun simctl terminate "$UDID" "$BID" >/dev/null 2>&1 || true
sleep 2

REQUIRED=(StarUnlock_Achievements StarUnlock_LevelStars StarUnlock_TotalTimePlayed StarUnlock_CurrentStreak StarUnlock_HighestStreak LevelProgression_TotalStars)
missing=0
for key in "${REQUIRED[@]}"; do
  if plutil -extract "$key" raw -o - "$PLIST" >/dev/null 2>&1; then
    echo "  ok      $key"
  else
    echo "  MISSING $key"; missing=1
  fi
done
if plutil -extract UnifiedDataMigration_v1_completed raw -o - "$PLIST" 2>/dev/null | grep -q true; then
  echo "  ok      UnifiedDataMigration_v1_completed = true (migration ran)"
else
  echo "  WARN    migration flag not set (migration did not run?)"; missing=1
fi

if [ "$missing" -ne 0 ]; then
  echo "FAIL: 起動後に旧キーが消えている（#18 の再現）"; exit 1
fi
echo "PASS: 旧キーは起動後も保持されている"
