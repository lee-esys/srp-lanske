# 🎾 Lanske（らんすけ）

ダブルスの組み合わせを生成するアプリケーション。

---

## 🚀 概要

Lanske は、テニスのダブルス練習やイベントにおいて
「偏りの少ない組み合わせ」を生成するためのツールです。

現在は開発初期段階です。

---

## 💻 開発環境

本プロジェクトは **GitHub Codespaces** 上で開発可能です。

### 起動手順

1. GitHub 上で「Code」→「Codespaces」→「Create codespace」
2. 起動後、ターミナルで実行

```bash
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
````

3. ブラウザでプレビューを確認

---

## 🧱 プロジェクト構成

```text
lib/
├─ app/                # アプリ全体設定
├─ features/
│  └─ doubles_scheduler/
└─ shared/             # 共通部品
```

---

## 📦 実装状況

* [x] プロジェクト構造
* [ ] ダブルス組み合わせ画面
* [ ] mock生成フロー
* [ ] アルゴリズム実装（core）

---

## 📚 ドキュメント

* [Architecture](docs/architecture.md)
* [Contributing Guide](docs/contributing.md)

---

## 🔐 設計方針

本プロジェクトでは以下を重視します：

* UIとロジックの分離
* アルゴリズムの分離（別リポジトリ）

アルゴリズム本体は `srp-lanske-core` にて管理予定。

---

## 🚧 今後の予定

* ダブルス組み合わせ生成ロジック
* 評価関数の設計
* UI改善
* Firebase連携

---

## 💡 コンセプト

> ランダムではなく、納得できる組み合わせを
