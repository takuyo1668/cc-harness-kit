# SETUP.md — Claude 向けセットアップ作業指示書

あなた（Claude）は、この配布キット `cc-harness-kit` をユーザーの環境に再現する担当です。
この1枚に従えばセットアップが完結します。**ユーザーの確認を挟みながら**進めてください。

## 担当の分担（最初にユーザーへ宣言する）
- **Claudeが行う層**: ファイル配置・プレースホルダ置換・フックの実行権限付与・動作確認
- **人間がGUI/手動で行う層（最後にチェックリストで提示）**: MCPサーバー接続・モデル契約・無人自動化の有効化

---

## 手順0a: 前提ツール確認（まっさらなマシン対応）

以下を存在チェックし、不足があればユーザーに導入手順を提示して待つ（Claudeは代行しない）。

- `git` — `git --version`
- `python3` — `python3 --version`（フック `pretool-guard.sh` / `prompt-logger.sh` が依存。macOSなら `xcode-select --install`）
- `jq` — `jq --version`（`web-evaluator.sh` が依存。無くても他は動く。macOSなら `brew install jq`）
- Claude Code 自身は動いている＝導入済み

## 手順0b: ヒアリング（AskUserQuestion で1回だけ）

以下のプレースホルダを埋めるため、ユーザーに質問する。**推測で埋めない**。

- `{{ROLE}}` — 役割/職種（例: ソロ開発者、エンジニア、マーケター兼エンジニア）
- `{{LANG}}` — コミュニケーション言語（例: 日本語）
- `{{OS}}` — OS（macOS / Windows / Linux）
- 主要プロジェクト（任意）— プロジェクト一覧表に入れる名前・パス・種別・状態。無ければ空テンプレのままにする
- MCPサーバー（任意）— 接続予定のもの（Google Calendar / Slack / Drive 等）。無ければ空にする
- 外部ノートアプリ（任意）— Obsidian等を使うか。使わないなら save.md の該当手順はスキップと伝える

**置換しない例外**: `settings.json` 内の `$HOME` と、フック内の `$HOME` / `$CLAUDE_PROJECT_DIR` は
シェルが解決する変数なので**そのまま残す**。スキル内の `{project}` など実行時に決まる変数も置換しない。

## 手順1: バックアップ（既存環境がある場合）

`~/.claude` が既に存在する場合、ユーザーに確認の上でバックアップを促す:

````
cp -R ~/.claude ~/.claude.bak.$(date +%Y%m%d)
[ -f ~/CLAUDE.md ] && cp ~/CLAUDE.md ~/CLAUDE.md.bak.$(date +%Y%m%d)
````

## 手順2: ファイル配置（差分確認しながら）

`harness/` の中身を配置する。**既存ファイルがある場合は上書き前に必ず差分を見せて確認を取る**。

- `harness/settings.json` → `~/.claude/settings.json`
- `harness/settings.local.example.json` → `~/.claude/settings.local.json`（コピーして各自編集する見本）
- `harness/context-essentials.md` → `~/.claude/context-essentials.md`
- `harness/rules/` → `~/.claude/rules/`
- `harness/hooks/` → `~/.claude/hooks/`
- `harness/agents/` → `~/.claude/agents/`
- `harness/commands/` → `~/.claude/commands/`
- `harness/skills/` → `~/.claude/skills/`
- `harness/CLAUDE.md` → `~/CLAUDE.md`（グローバルに効かせる場合）。特定プロジェクトだけに効かせたいなら、そのプロジェクト直下に置く

配置例（既存が無い前提。ある場合は1ファイルずつ確認）:

````
mkdir -p ~/.claude/rules ~/.claude/hooks ~/.claude/agents ~/.claude/commands ~/.claude/skills
cp harness/settings.json ~/.claude/settings.json
cp harness/settings.local.example.json ~/.claude/settings.local.json
cp harness/context-essentials.md ~/.claude/context-essentials.md
cp harness/rules/*.md ~/.claude/rules/
cp harness/hooks/*.sh ~/.claude/hooks/
cp harness/agents/*.md ~/.claude/agents/
cp -R harness/commands/* ~/.claude/commands/
cp -R harness/skills/* ~/.claude/skills/
cp harness/CLAUDE.md ~/CLAUDE.md
````

## 手順3: プレースホルダ置換

手順0bの回答を使い、以下2ファイルの `{{...}}` を置換する。回答が無い項目はテンプレの説明文を残す。
- `~/CLAUDE.md`
- `~/.claude/context-essentials.md`

置換後、`grep -rn '{{' ~/CLAUDE.md ~/.claude/context-essentials.md` で**必須の置換漏れが無いか**確認する。
以下の残置はOK（ユーザーに残置の意図を伝える）: プロジェクト一覧表・MCP例・空テンプレ項目・
「`{{...}}` を置き換えてください」というガイド文中の `{{...}}` リテラルそのもの。

## 手順4: フックの実行権限とパス確認

````
chmod +x ~/.claude/hooks/*.sh
````

`settings.json` のフックパスは `$HOME/.claude/hooks/...` になっている。`$HOME` が正しく解決されるか、
手順6のテストで確認する。

## 手順5: 人間がGUI/手動で行う層（チェックリストとして提示）

以下はClaudeが代行できない。ユーザーに一覧で渡す:
- [ ] 使いたい MCP サーバーを接続する（Claude Code の設定 or `claude mcp add`）
- [ ] `settings.json` の `"model"` を自分の契約に合わせる（`opusplan` は Plan=Opus / 実行=別 の意。不要なら任意のモデル名へ）
- [ ] 頻出の読み取り専用コマンドや使うMCPツールを `settings.local.json` の allow に追記（確認プロンプト削減）
- [ ] （任意）無人自動化を使う場合の有効化 — **Claudeは実行しない。コマンドを提示するのみ**

## 手順6: 動作確認（必ず実行し、結果を見せる）

1. **pretool-guard（事故ブロック）のテスト** — 破壊コマンドが deny されるか:
   ````
   echo '{"tool_name":"Bash","tool_input":{"command":"DROP TABLE x"}}' | ~/.claude/hooks/pretool-guard.sh
   ````
   期待: `"permissionDecision":"deny"` を含むJSONが返る。返らなければ python3 の有無とパスを確認。
   （注: 既にこの環境で pretool-guard が稼働している場合、`DROP TABLE` を含むコマンド文字列自体が
   guard に弾かれてテストできない。そのときは payload を一時ファイルに保存し `< payload.json` で渡す。
   まっさらな新規マシンでは未導入なので不要。）

2. **prompt-logger のテスト** — ログが1行追記されるか:
   ````
   echo '{"session_id":"test","cwd":"/tmp","prompt":"セットアップテスト"}' | ~/.claude/hooks/prompt-logger.sh
   ls ~/.claude/prompt-log/
   ````
   期待: `YYYY-MM.jsonl` が作られ、1行追記される。

3. **harness-health のテスト** — エラーなく終了するか（MEMORY.md が無ければ無出力でOK）:
   ````
   ~/.claude/hooks/harness-health.sh; echo "exit=$?"
   ````
   期待: `exit=0`。

4. **設定の読み込み確認** — Claude Code を再起動し、SessionStart で異常が出ないこと、
   `outputStyle: Explanatory` が効いていることを確認。

テストで作った一時ファイル（prompt-log のテスト行など）は、ユーザーに掃除の許可を取ってから消す。

## 手順7: 完了報告フォーマット

以下の形で報告する:

````
✅ cc-harness-kit セットアップ完了

配置したもの:
- ~/.claude/{settings.json, context-essentials.md, rules/, hooks/, agents/, commands/, skills/}
- ~/CLAUDE.md（プレースホルダ置換: {{ROLE}}={...} 等）

動作確認:
- pretool-guard: DROP TABLE を deny ✅
- prompt-logger: ログ追記 ✅
- harness-health: exit=0 ✅

あなたに残る作業（GUI/手動）:
- [ ] MCP サーバー接続
- [ ] model 設定の確認
- [ ] （任意）無人自動化の有効化

まず試すおすすめ: 実装タスクの完了報告前に `verification-before-completion`、
思考タスクの前に `logical-thinking` を使ってみてください。
````
