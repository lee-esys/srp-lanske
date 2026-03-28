# 🤝 Contributing Guide

このプロジェクトの開発ルール・運用方針をまとめる。

---

## 🧭 基本方針

- 小さく作る
- 構造を守る
- アルゴリズムとアプリを分離する
- 再現性のある実装を意識する

---

## 🌿 ブランチ戦略

### main

- 安定ブランチ
- 直接コミット禁止
- Pull Request 経由でのみ更新

---

### feature/*

- 作業用ブランチ
- 1ブランチ = 1目的
- Issue単位で作成する

例：

```

feature/1-project-structure
feature/2-page-skeleton
feature/3-mock-generation-flow

```

---

### Issueとクローズのルール

- 親Issue（ブランチ単位）は、`main` への merge 時に `closes #issue` とする
- 子Issue / 関連Issue（小タスク単位）は、該当コミットで `closes #issue` としてよい
- 作業途中のコミットでは `refs #issue` を使用する

例：

```

🔌 feat: add scheduler controller closes #7 refs #3
🖼️ feat: add result view refs #3

```

最終マージ時：

```

🔌 feat: add mock schedule generation flow closes #3

```

---

## 🔀 開発フロー

1. `main` を最新化
2. `feature/*` を作成
3. 実装
4. コミット
5. Push
6. Pull Request 作成
7. 動作確認
8. `Squash and merge`
9. ブランチ削除

---

## ✍️ コミットメッセージ規約

### フォーマット

```

<emoji> <type>: <summary> [refs #issue]

```

または

```

<emoji> <type>: <summary> closes #issue

```

---

### 例

```

🏗️ chore: initialize project structure refs #1
🖼️ feat: add doubles scheduler page skeleton refs #2
🔌 feat: add mock schedule generation flow refs #3
♻️ refactor: split scheduler form widget refs #5
🐛 fix: handle invalid player count input refs #8
📝 docs: update architecture for core separation refs #10

```

---

### type 一覧

- `feat` : 機能追加
- `fix` : バグ修正
- `refactor` : リファクタリング
- `chore` : 構造・設定・雑務
- `docs` : ドキュメント
- `test` : テスト
- `remove` : 削除

---

### 絵文字一覧

```

🏗️ chore:
✨ feat:
🖼️ feat:
🔌 feat:
🐛 fix:
♻️ refactor:
📝 docs:
✅ test:
🔥 remove:
🚚 chore:
🔒 chore:

```

---

## 🧱 アーキテクチャ方針

- presentation / application / domain / infrastructure を分離
- UIとロジックを分離
- アルゴリズムは core 側へ切り出す

---

## 🔐 アルゴリズムの扱い

- 本リポジトリにはアルゴリズム本体を含めない
- repository 経由で接続する
- core リポジトリで管理する

---

## 🧪 実装ルール

- controller にロジックを書かない
- UseCase に責務を寄せる
- mock 実装でも repository を通す
- 1コミット1目的を意識する

---

## 📌 注意事項

- 機密情報を含めない
- `.env` や認証情報はコミットしない
- `.gitignore` を遵守する

---

## 🚧 今後の拡張

- round_robin
- knockout
- score

feature単位で拡張していく

---

## 💡 判断基準

実装に迷った場合は、以下の観点を優先する：

> ランダムではなく、納得できる組み合わせを
