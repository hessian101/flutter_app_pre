# Star Music Game

星座画像から音楽を生成するリズムゲームアプリです。

## 概要

Star Music Gameは、ユーザーがアップロードした星座の画像を解析し、星の位置と配置に基づいて音楽とリズムゲームを生成するモバイルアプリケーションです。

### 主な機能

- **星座画像解析**: カメラやギャラリーから星座画像をアップロード
- **音楽生成**: 星の位置データから自動的にリズムゲームを生成
- **リアルタイムゲームプレイ**: タップタイミングでスコア判定（Perfect/Good/Miss）
- **演奏録音**: ゲーム中の演奏を音声録音し、WAVファイルとして保存
- **ハイスコア記録**: 過去のスコアをデータベースに保存・管理
- **演奏再生**: 保存した演奏記録の再生・管理

## 技術スタック

- **Frontend**: Flutter
- **Database**: SQLite (ローカルストレージ)
- **Audio**: just_audio, record パッケージ
- **State Management**: Provider
- **Image Processing**: image_picker
- **HTTP**: http パッケージ

## セットアップ

### 前提条件

- Flutter SDK (3.9.2+)
- Dart SDK
- Android Studio / Xcode (各プラットフォーム用)

### インストール

1. リポジトリをクローン
```bash
git clone <repository-url>
cd flutter_sample
```

2. 依存関係をインストール
```bash
flutter pub get
```

3. アプリを実行
```bash
flutter run
```

### 権限設定

このアプリは以下の権限が必要です：

- **RECORD_AUDIO**: 演奏の録音
- **CAMERA**: カメラでの星座画像撮影
- **READ_EXTERNAL_STORAGE**: ギャラリーからの画像選択
- **WRITE_EXTERNAL_STORAGE**: 録音ファイルの保存
- **INTERNET**: API通信（画像解析）

## アーキテクチャ

```
lib/
├── models/          # データモデル
│   ├── high_score.dart
│   ├── saved_song.dart
│   └── star_data.dart
├── screens/         # UI画面
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── result_screen.dart
│   ├── highscore_screen.dart
│   ├── performance_list_screen.dart
│   ├── settings_screen.dart
│   └── how_to_play_screen.dart
├── services/        # ビジネスロジック
│   ├── database_service.dart
│   ├── audio_service.dart
│   └── api_service.dart
├── utils/           # ユーティリティ
│   ├── constants.dart
│   └── audio_utils.dart
└── main.dart        # アプリケーションエントリーポイント
```

## データベーススキーマ

### HighScore テーブル
```sql
CREATE TABLE HighScore (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    score INTEGER NOT NULL,
    accuracy REAL NOT NULL,
    combo_max INTEGER NOT NULL
);
```

### SavedSong テーブル
```sql
CREATE TABLE SavedSong (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    file_path TEXT NOT NULL,
    score INTEGER NOT NULL,
    accuracy REAL NOT NULL
);
```

## 使用方法

1. **ホーム画面**: アプリを起動し、「ゲーム開始」をタップ
2. **画像選択**: 星座画像をカメラで撮影またはギャラリーから選択
3. **ゲームプレイ**: 生成された音楽に合わせてノートをタップ
4. **結果確認**: スコアと精度を確認し、演奏の保存を選択
5. **記録管理**: ハイスコアや演奏記録を後から確認・再生

## 開発状況

- ✅ 基本的なUI/UX実装
- ✅ データベース機能
- ✅ 音声録音・再生機能
- ✅ ゲームメカニクス
- ✅ API統合（デモモード）
- 🔄 画像解析API連携
- 🔄 音声合成機能
- 🔄 追加設定機能

## ライセンス

MIT License

## 貢献

プルリクエストとイシューを歓迎します。大きな変更を行う場合は、まずイシューを開いて変更について議論してください。
