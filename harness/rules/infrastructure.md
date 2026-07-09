# インフラ・デプロイ作業時のルール

本番環境・CI/CD・環境変数・ドメイン設定を含む作業では以下を遵守する。

## 本番デプロイ
- デプロイ先が本番（Railway production / GAS本番 / Vercel prod 等）の場合、コマンド発行前に「本番環境にデプロイします。対象: [環境名]。よいですか？」と確認
- ステージング/開発環境への単独デプロイは確認不要
- デプロイ「完了」発言はビルドSuccess確認後のみ。env var適用とユーザー「done」も裏取り必須
- Railway の完了判定は `railway deployment list` で当該デプロイIDが SUCCESS かつ最新（アクティブ）であることを確認。`railway logs --build` は古い成功ビルドを返すことがあるため信用しない
- git push はClaude実行可だが毎回ユーザー確認必須（settings.json の permissions.ask で機械的に担保。2026-06-11方針変更）。force push 系は引き続き deny で全面ブロック。デプロイ前に未コミット変更がないか確認する

## DBマイグレーション
- 本番適用前にドライラン（`prisma migrate diff` / `--dry-run` / SELECT で影響件数確認）
- 影響行数を提示してから承認を得る
- カラム削除・テーブル削除を含むマイグレーションは「データが失われます」と警告
- ロールバック手順を事前に提示

## 環境変数
- 追加・変更は影響範囲（どのサービスが参照するか）を明示
- Railway は env をブラウザ経由で登録（CLIだとMacスマート引用符でクラッシュ）
- SQL/env値などコピペ実行データは `pbcopy` 経由で渡す

## 不可逆操作（自動ストップ）
以下は実行前に必ず「これは復旧不可能な操作です。実行してよいですか？」と確認:
- `rm -rf`
- `git push --force` / `git push -f`
- `git reset --hard`
- `git checkout .` / `git restore .` / `git clean -f`
- `DROP TABLE` / `DROP DATABASE` / `TRUNCATE`
- WHERE句なしの `DELETE FROM`
- `railway down` / `heroku destroy`
- 本番への `clasp push --force`
- `prisma migrate reset` / `--force` 系全般

## CI/CD
- pre-commit / pre-push フックは `--no-verify` でスキップしない（明示指示時のみ）
- フォーマット・lint・型チェック・テストはCI前にローカルで通す

## ロールバック計画
- 本番変更前にロールバック手順を文書化
- 過去2リリース分のロールバック可能性を維持
