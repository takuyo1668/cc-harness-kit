# Claude に貼り付ける起動指示文

下の枠の中身をコピーして、`cc-harness-kit` ディレクトリで起動した Claude Code に貼り付けてください。
Claude が `SETUP.md` を読み、あなたに確認しながら環境を構築します。

---

```
このディレクトリは Claude Code 運用環境の配布キット（cc-harness-kit）です。
同梱の SETUP.md を読み、その手順に従って私の環境（~/.claude と ~/CLAUDE.md）に
このハーネスをセットアップしてください。

守ってほしいこと:
- 既存ファイルがある場合は上書きせず、必ず差分を見せて私に確認してから反映する
- CLAUDE.md / context-essentials.md の {{...}} プレースホルダは、
  SETUP.md の手順0のヒアリングで私に質問してから埋める（勝手に推測して埋めない）
- フック（hooks/*.sh）を配置したら、実際に1回動かして動作確認する
- 無人自動化の有効化コマンドは、実行せず私に提示するだけにする
- 秘密情報・APIキーは一切ファイルに書かない

まず SETUP.md を読んで、作業計画を提示してください。
```

---

## キットの中身（Claude が参照する）
- `harness/` — 配置する実ファイル一式
- `SETUP.md` — Claude 向けの詳細な作業指示書
- `docs/CUSTOMIZE.md` — プレースホルダの記入ガイド
- `docs/ARCHITECTURE.md` — 設計思想（なぜこの構造か）
- `docs/SKILLS.md` — スキルの使い方
