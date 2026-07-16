# SETUP.md — Claude 向け CodeGraph セットアップ作業指示書

あなた（Claude）は、CodeGraph（コードナレッジグラフ）をユーザーの環境に導入する担当です。
この1枚に従えばセットアップが完結します。**ユーザーの確認を挟みながら**進めてください。

## 担当の分担（最初にユーザーへ宣言する）

- **Claude が行う層**: CLI インストール・テレメトリ無効化・プロジェクト設定ファイル生成・インデックス構築・動作確認
- **人間が行う層（最後にチェックリストで提示）**: Claude Code の再起動（MCP サーバー読み込みに必要）、
  設定ファイルを git にコミットするかの判断

## このキットの方針（変更しない）

- バージョンは **1.4.1 にピン留め**する（2026-07-16 にセキュリティ監査済みのバージョン。自動更新させない）
- テレメトリ（匿名利用統計）は**必ず無効化**する
- MCP 登録は**プロジェクトローカル**（対象プロジェクト内の `.mcp.json`）に限定する。
  `~/.claude.json` へのグローバル登録や `codegraph install`（公式一括インストーラ）は**使わない**
  — 全プロジェクトのセッションに常駐プロセスが増えるのを避けるため

---

## 手順0a: 前提ツール確認（まっさらなマシン対応）

以下を存在チェックし、不足があればユーザーに導入手順を提示して待つ（Claude は代行しない）:

- `node` / `npm` — `node -v`（v18 以上を推奨）。無ければ「https://nodejs.org から LTS 版をインストール、
  または `brew install node`」を提示して待つ
- Claude Code 自身は動いている＝導入済み

## 手順0b: ヒアリング（AskUserQuestion で1回だけ）

プレースホルダを埋めるため質問する。**推測で埋めない**。

- `{{PROJECT_PATH}}` — CodeGraph を導入するプロジェクトの絶対パス（複数可）。
  聞く前に候補プロジェクトのソースファイル数を実測し、**約50ファイル未満のものは「効果が薄い」と伝えて対象から外すことを推奨**する:

  ```bash
  find <パス> -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.go' -o -name '*.astro' -o -name '*.vue' \) -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/.next/*' | wc -l
  ```

**置換しない例外**: この指示書に埋め込まれた生成ファイル本文の中に `{{...}}` 形式はない。
生成ファイルは**一字一句そのまま**書き込む。

## 手順1: CLI インストール（ピン留め）

```bash
npm i -g @colbymchenry/codegraph@1.4.1
codegraph version   # → 1.4.1 と表示されること
```

## 手順2: テレメトリ無効化

```bash
codegraph telemetry off
codegraph telemetry status   # → disabled と表示されること
```

## 手順3: プロジェクトごとの設定ファイル生成（対象プロジェクトぶん繰り返す）

各 `{{PROJECT_PATH}}` に対して3ファイルを配置する。

### 3-1. `{{PROJECT_PATH}}/.mcp.json`

**既に存在する場合**は上書きせず、`mcpServers` に `codegraph` キーだけをマージ追加する。無ければ以下の全文で新規作成:

````json
{
  "mcpServers": {
    "codegraph": {
      "type": "stdio",
      "command": "codegraph",
      "args": ["serve", "--mcp"]
    }
  }
}
````

### 3-2. `{{PROJECT_PATH}}/.claude/settings.json`

**既に存在する場合**は `permissions.allow` 配列に `"mcp__codegraph__*"` を1要素追加するだけにする。無ければ以下の全文で新規作成:

````json
{
  "permissions": {
    "allow": [
      "mcp__codegraph__*"
    ]
  }
}
````

### 3-3. `{{PROJECT_PATH}}/CLAUDE.md` へのブロック追記

ファイル末尾に以下を**本文を改変せず**追記する（CLAUDE.md が無ければこのブロックだけで新規作成）。
マーカーコメントは撤去時の目印なので必ず含める:

````markdown
<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.

**Before editing a shared/exported symbol**: check its blast radius first — `codegraph impact <symbol>` (or the blast-radius section already included in explore output) — and verify each listed dependent still works after the change.
<!-- CODEGRAPH_END -->
````

## 手順4: インデックス構築

```bash
cd {{PROJECT_PATH}} && codegraph init
codegraph status   # Files / Nodes / Edges の数値が出ること
```

`status` の Files・Nodes・Edges の数値を控える（完了報告に使う）。

## 手順5: 動作確認（証拠を取ってから完了と言う）

1. **実クエリ**: そのプロジェクトに実在する機能名で試す:

   ```bash
   cd {{PROJECT_PATH}} && codegraph explore "<実在する機能や関数の名前>"
   ```

   関連シンボルのソースと Blast radius セクションが返れば合格。

2. **影響範囲**: 手順5-1 の explore 結果に出てきた関数名を1つ選び:

   ```bash
   codegraph impact <その関数名>
   ```

   affected symbols の一覧が返れば合格。

3. **git 安全確認**（git 管理下のプロジェクトのみ）:

   ```bash
   cd {{PROJECT_PATH}} && git check-ignore .codegraph/ && echo OK
   ```

   `.codegraph/` は自己 gitignore されるので OK が出るはず。出ない場合のみ `.gitignore` に `.codegraph/` を追記。

## 手順6: 完了報告

以下のフォーマットで報告し、**人間チェックリスト**を提示する:

```
## CodeGraph セットアップ完了
- CLI: v1.4.1（ピン留め）/ テレメトリ: 無効
- 対象: <プロジェクト名> — <N>ファイル → <N>ノード・<N>エッジ
- 動作確認: explore ✓ / impact ✓ / gitignore ✓

## あなた（人間）に残る作業
1. Claude Code を再起動する（このプロジェクトを開き直す）— MCP サーバーが読み込まれます
2. .mcp.json / .claude/settings.json / CLAUDE.md の変更をコミットするかチームで判断
   （コミットすればチーム全員に設定が共有されます。索引 .codegraph/ 自体はコミットされません）
```

---

## 撤去手順（ユーザーに聞かれたら）

1. `codegraph uninit {{PROJECT_PATH}}` — プロジェクトの索引削除
2. `.mcp.json` の `codegraph` キー、`.claude/settings.json` の `mcp__codegraph__*`、
   CLAUDE.md の `<!-- CODEGRAPH_START -->`〜`<!-- CODEGRAPH_END -->` を削除
3. `npm rm -g @colbymchenry/codegraph` — CLI 本体の削除

## バージョン更新の方針（ユーザーに聞かれたら）

自動更新はしない。新バージョンに上げる場合は、リリースノートを確認のうえ
`npm i -g @colbymchenry/codegraph@<新バージョン>` で明示的にピン留めし直す。
