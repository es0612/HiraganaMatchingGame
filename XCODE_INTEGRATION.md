# Xcode 統合設定ガイド

このドキュメントでは、SwiftLint と SwiftFormat を Xcode に統合する方法を説明します。

## SwiftFormat の Xcode 統合

### 方法1: Run Script Phase の追加 (推奨)

1. Xcode で `HiraganaMatchingGame.xcodeproj` を開く
2. プロジェクト設定で `HiraganaMatchingGame` ターゲットを選択
3. `Build Phases` タブを開く
4. `+` ボタンをクリックして `New Run Script Phase` を選択
5. 新しいスクリプトフェーズの名前を `SwiftFormat` に変更
6. スクリプト内容を以下にする：

```bash
if which swiftformat >/dev/null; then
  echo 'Running SwiftFormat'
  swiftformat .
else
  echo 'warning: SwiftFormat not installed. Install with: brew install swiftformat'
fi
```

7. `Based on dependency analysis` のチェックを外す（毎回実行するため）
8. SwiftLint の Run Script Phase より **前** に配置する

### 方法2: Build Tool Plugin (Xcode 14+)

Package.swift で SwiftFormat を Build Tool Plugin として設定することも可能です。

## 現在の統合状況

### ✅ 設定済み
- **SwiftLint**: Run Script Phase で自動実行
- **CI/CD**: GitHub Actions で両方のツールを実行

### 📝 手動設定が必要
- **SwiftFormat**: Xcode Run Script Phase への追加（上記参照）

## Build Phase の実行順序

正しい実行順序：
1. `SwiftFormat` - コードフォーマット
2. `SwiftLint` - コード品質チェック
3. `Sources` - コンパイル

## トラブルシューティング

### SwiftFormat が見つからない場合
```bash
brew install swiftformat
```

### 実行時間が長い場合
差分のみチェックするスクリプト：

```bash
if which swiftformat >/dev/null; then
  if [ "$ACTION" = "build" ]; then
    echo 'Running SwiftFormat on changed files'
    git diff --diff-filter=d --name-only | grep -E '\\.swift$' | xargs swiftformat
  fi
else
  echo 'warning: SwiftFormat not installed'
fi
```

### 設定の無効化
特定のファイルや行で SwiftFormat を無効にする：

```swift
// swiftformat:disable
let unformattedCode = "keep as is"
// swiftformat:enable
```

## 検証

設定後、以下で動作を確認：

```bash
# 手動実行
./scripts/lint.sh

# Xcode でビルド実行時に Run Script が動作することを確認
```