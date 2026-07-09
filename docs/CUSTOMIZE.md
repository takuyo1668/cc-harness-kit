# CUSTOMIZE — あなたの情報を記入するガイド

このキットは「型」だけを配っています。あなたの環境で精度を出すには、以下の穴埋めをしてください。
**個人情報・秘密情報（APIキー・トークン・パスワード）はここにも書かないこと。**

---

## 必須の穴埋め（`{{...}}` プレースホルダ）

### `~/CLAUDE.md`
| プレースホルダ | 記入内容 |
|---|---|
| `{{あなたの役割・職種}}` | 例: ソロ開発者 / バックエンドエンジニア / マーケター兼エンジニア |
| `{{日本語 など}}` | コミュニケーション言語 |
| プロジェクト一覧表 | あなたの主要プロジェクトの名前・パス・種別・状態。**この表を唯一の正本にする**（他ファイルに転記しない） |
| MCPサーバー | 接続しているMCPと用途。無ければ空でよい |

### `~/.claude/context-essentials.md`
| プレースホルダ | 記入内容 |
|---|---|
| `{{あなたの役割}}` | CLAUDE.md と同じ |
| `{{日本語}}` | 言語 |
| `{{macOS / Windows / Linux}}` | OS |
| プロジェクト状況 | 現在の主要プロジェクトと状態を数行 |

置換後の確認:
````
grep -rn '{{' ~/CLAUDE.md ~/.claude/context-essentials.md
````
プロジェクト表など「空テンプレのまま残してよい」箇所以外に `{{` が残っていないか見る。

---

## 任意の設定

### モデル（`~/.claude/settings.json` の `"model"`）
- `opusplan` = Plan mode では Opus、実行では別モデル、という混成設定。
- 自分の契約・好みに合わせて変更してよい。特にこだわりが無ければそのままで可。

### 出力スタイル（`"outputStyle"`）
- `Explanatory` = 実装の合間に教育的な解説を挟むスタイル。学びながら使いたい人向け。
- 端的な応答が好みなら `/output-style` で変更、または設定を消す。

### マシンごとの追加許可（`~/.claude/settings.local.json`）
- `settings.local.example.json` をコピーして作る。git管理しない（`.gitignore` 済み）。
- よく使う読み取り専用コマンドや、使うMCPツールを allow に足すと確認プロンプトが減る。
- 例: `"WebFetch(domain:github.com)"`, `"Bash(pbcopy)"`, `"mcp__slack__slack_post_message"`

### MCPサーバー接続
- カレンダー・Slack・Drive などを使うなら Claude Code の設定または `claude mcp add` で接続する。
- 接続したら `~/CLAUDE.md` の「MCPサーバー」節にも用途を書いておくと Claude が活用しやすい。

### 外部ノートアプリ連携（任意）
- `save.md` と `design-review` は、Obsidian等のノートアプリへの保存を**任意手順**として持つ。
- 使う場合は保存先パスを自分の環境に合わせて各ファイルに追記する。使わないならスキップでよい。

---

## 育てていく部分

- **CLAUDE.md / feedback memory**: ミスや好みが分かったら即追記する。これが「使うほど賢くなる」の実体。
- **design-review の学習**: `preferences.md` / `patterns.md` は使うたびに自動で育つ（配布時は空）。
- **ルールの棚卸し**: 月1回 `/weekly-review` で「不要になったルール」を削る。増やすより減らす意識を持つ。

---

## 最小構成で始めたい人へ

全部入れなくてよい。**効果が大きい順**に3段階:

1. **まず事故防止と検証**（これだけで体感が変わる）:
   `settings.json`（deny）+ `hooks/pretool-guard.sh` + `skills/verification-before-completion`
2. **次に思考と運用**:
   `CLAUDE.md`（本質5原則）+ `skills/logical-thinking` + `rules/`
3. **最後に専門スキル**:
   `agents/` + `commands/` + 残りの `skills/`
