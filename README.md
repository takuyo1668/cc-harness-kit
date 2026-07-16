# cc-harness-kit — Claude Code 運用環境の配布キット

Claude Code を「推測で動くアシスタント」ではなく「検証しながら確実に仕事を終えるパートナー」に変える、
設定・ルール・自動化・スキルの一式です。実際に日々の開発・マーケティング業務で使い込んでチューニングした
環境から、個人情報とプロジェクト固有情報を取り除いて汎用化したものを配布します。

> **Claude Code とは**: Anthropic 製のコマンドライン用 AI コーディングツール。ターミナル上で対話しながら
> ファイル編集・コマンド実行・調査を任せられる。このキットはその Claude Code の「振る舞い」を設定で作り込む。

---

## これで何が変わるか

素の Claude Code も優秀ですが、次の3点が「精度の差」を生みます。このキットはその3点を仕組みで担保します。

1. **推測で「できました」と言わせない** — 実装・修正の完了報告前に、テストや動作確認の証拠を自己照合する
   ゲート（`verification-before-completion`）を通す。「動くはず」を禁止する。
2. **事故を機械的に止める** — `rm -rf` / force push / `DROP TABLE` などの復旧不可能な操作を、
   許可設定（`settings.json` の deny）とフック（`pretool-guard.sh`）の2層でブロックする。
3. **考える前に型を選ばせる** — 分析・意思決定・戦略などの思考タスクで、いきなり書き始めず
   思考フレームワークの索引（`logical-thinking`）から最適な型を選んでから考える。

加えて、デザインレビュー・市場調査・プロジェクト管理などを「使うたびに精度が上がる」スキルとして同梱しています。

---

## 中身（何が入っているか）

```
harness/                     ← あなたの ~/.claude と ~/CLAUDE.md にコピーする実ファイル
  CLAUDE.md                  全セッションで読まれる運用ルールの本体（テンプレート）
  context-essentials.md      長い会話が自動要約された後も保持したい原則
  settings.json              許可/拒否/フック/モデルの設定（事故防止の核）
  settings.local.example.json マシンごとの追加許可の見本
  rules/                     領域別ルール（backend / frontend / infrastructure）
  hooks/                     フック（下記4種のシェルスクリプト）
  agents/                    22種の専門サブエージェント定義
  commands/                  スラッシュコマンド（/pm /save /weekly-review 等）
  skills/                    自作の汎用スキル（下記）
docs/
  ARCHITECTURE.md            「どういう前提で動くか」= 設計思想の解説
  SKILLS.md                  収録スキルの一覧と使い方
  CUSTOMIZE.md               あなたの情報を記入するガイド（穴埋め箇所の一覧）
PROMPT.md                    セットアップを Claude に任せるための貼り付け文
SETUP.md                     Claude 向けの詳細な作業指示書
```

### 収録スキル（自作・汎用）
- `logical-thinking` — 思考フレームワーク85種の索引。考える前に型を選ぶ
- `verification-before-completion` — 完了報告前の「証拠なき完了」封じゲート
- `design-review` — UI/UXを3エージェント並列でレビュー。使うほど好みを学習
- `ui-design-quality` — 大量画面のデザイン品質を保つWave方式
- `oss-import` — GitHub上のOSS（スキル/プラグイン）を安全に自環境へ取り込む判断ゲート
- `setup-kit-share` — 自分の環境を他人が再現できる配布キットにする（このキット自体の作り方）
- `slack` — 保存した情報をSlack共有文へ選択式で変換

### 収録コマンド
`/pm`（プロジェクト管理）`/save`（会話の保存）`/weekly-review`（週次振り返り）
`/ship-check`（デプロイ前チェック）`/market-research`（市場調査）`/health-check`（Mac環境診断）

> Anthropic 公式プラグインのスキル（copywriting, paid-ads, skill-creator 等）は
> このキットに含めません。各自プラグインから入手できます。詳細は `docs/SKILLS.md`。

### 追加キット: codegraph-kit（コードのナレッジグラフ化）

`codegraph-kit/` は本体とは独立に導入できる追加キットです。OSS の CodeGraph を使って
プロジェクトのコードを索引化（ナレッジグラフ化）し、「この関数を変えたらどこが壊れるか」
「この機能はどこと繋がっているか」を Claude が1コールで答えられるようにします。
導入は `codegraph-kit/GUIDE.md` から。

---

## セットアップ（3通り）

### 方法A: Claude に任せる（推奨・らくちん）
1. このリポジトリをクローンする: `git clone <このリポジトリのURL> && cd cc-harness-kit`
2. Claude Code を起動する: `claude`
3. `PROMPT.md` の中身をコピーして Claude に貼り付ける
4. Claude が `SETUP.md` の手順に従って、確認しながらあなたの `~/.claude` に配置します

### 方法B: 手動でコピー
`docs/CUSTOMIZE.md` の手順に従って、`harness/` の中身を `~/.claude/` に、
`harness/CLAUDE.md` を `~/CLAUDE.md`（または各プロジェクト直下）に配置し、プレースホルダを埋めます。

### 前提ツール
- **Claude Code**（これを読んでいる時点で導入済みのはず）
- **git**（クローンに使用）
- **python3**（フックが依存。macOS は `xcode-select --install`）
- 一部コマンドは **jq**（`web-evaluator.sh` が使用）や各種MCP接続が前提

---

## よくある質問

**Q. 私のAPIキーやトークンは入っていますか?**
A. 入っていません。このキットは秘密情報・個人情報・顧客情報を一切含みません。設定は「型」だけです。

**Q. 既存の ~/.claude を上書きしませんか?**
A. 方法A（Claude に任せる）では、既存ファイルがある場合は必ず差分を見せて確認してから反映します。
   不安なら先に `cp -R ~/.claude ~/.claude.bak` でバックアップしてください。

**Q. 費用はかかりますか?**
A. キット自体は無料です。Claude Code の利用料はあなたの契約に準じます。フックやログ記録は
   ローカルで動くので追加課金はありません。

**Q. やめたいときは?**
A. `~/.claude/settings.json` の `hooks` セクションを消せばフックは止まります。
   スキル/コマンドはフォルダごと削除すれば消えます。`~/CLAUDE.md` を元に戻せばルールも外れます。

**Q. これを使うと本当に精度が上がりますか?**
A. 一番効くのは「検証ループ」と「事故の機械ブロック」です。まずこの2つ（`settings.json` と
   `hooks/` と `verification-before-completion`）だけ入れて体感してから、残りを足すのがおすすめです。

---

## 困ったら
- フックが動かない → `docs/ARCHITECTURE.md` の「フックのトラブルシューティング」
- 何を埋めればいいか分からない → `docs/CUSTOMIZE.md` の穴埋め一覧
- スキルの使い方 → `docs/SKILLS.md`
