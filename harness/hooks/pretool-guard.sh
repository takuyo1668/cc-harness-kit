#!/bin/bash
# PreToolUse ガード: 破壊コマンド・秘密情報の読み出し/外部送信を deny 返却で実際にブロックする
# 入力は stdin の JSON。2026-06-10 監査で no-op を修正。2026-06-19 jq依存を撤廃し python3 に統一（配布簡素化・Homebrew不要化）
# 実機テスト: echo '{"tool_name":"Bash","tool_input":{"command":"DROP TABLE x"}}' | pretool-guard.sh → deny JSON
#
# 位置づけ: 「うっかり事故」防止の最終層。悪意ある回避（r''m / base64 / 変数展開）は正規表現では原理的に防げない。
#           悪意対策は permissions(deny) + disableBypassPermissionsMode が担う。
# 依存: python3 のみ（利用集計hookと共通。jq不要＝Homebrew不要）。

INPUT=$(cat)

# JSON出力（理由は固定文字列のみ＝printf で安全。jq非依存）
emit() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' "$1" "$2"
  exit 0
}

# python3 は必須（利用集計hookと共通の依存）。無ければ素通りさせず deny（安全側）。
if ! command -v python3 >/dev/null 2>&1; then
  emit "deny" "python3 未インストールのため Bash ガードが機能しません（xcode-select --install）。管理者に連絡してください"
fi

# stdin JSON から tool_input.command を取り出す（python3 で解析・jq不要）
CMD=$(printf '%s' "$INPUT" | python3 -c 'import sys,json
try:
    d = json.load(sys.stdin)
    c = d.get("tool_input", {}).get("command", "")
    sys.stdout.write(c if isinstance(c, str) else "")
except Exception:
    pass' 2>/dev/null)

# command が取れない（Bash以外・空）なら素通り
[ -z "$CMD" ] && exit 0

deny() { emit "deny" "$1"; }
ask()  { emit "ask"  "$1"; }

# OSセキュリティ無効化・破壊コマンド（rm はフラグ順序違い -fr / --force 混在も捕捉）
if echo "$CMD" | grep -Eq 'spctl[[:space:]]+.*--master-disable|csrutil[[:space:]]+disable|rm[[:space:]]+(-[[:alnum:]-]+[[:space:]]+)*-{0,2}[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]+(/|~|\*|\$HOME)|rm[[:space:]]+(-[[:alnum:]-]+[[:space:]]+)*-{0,2}[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\*|\$HOME)'; then
  deny "OSセキュリティ無効化/破壊コマンドを遮断"
fi

# 不可逆DB操作（settings.json deny では塞げない psql -c 等の経由を含む）。TRUNCATE は語境界で TRUNCATED を除外
if echo "$CMD" | grep -Eiq 'DROP[[:space:]]+TABLE|DROP[[:space:]]+DATABASE|TRUNCATE[[:space:]]+(TABLE[[:space:]]+)?[`"'"'"'[:alnum:]]|prisma[[:space:]]+migrate[[:space:]]+reset|railway[[:space:]]+down|heroku[[:space:]]+.*destroy'; then
  deny "不可逆DB/インフラ操作を遮断。ユーザー承認後に手動実行してください"
fi

# git 破壊操作（origin main --force のように間に語が挟まる形・--force-with-lease も含む）
if echo "$CMD" | grep -Eq 'git[[:space:]]+push([[:space:]]+[^;&|]*)?[[:space:]]+(--force(-with-lease|-if-includes)?|-f)([[:space:]]|=|$)|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+clean[[:space:]]+-[a-z]*f|git[[:space:]]+(checkout|restore)[[:space:]]+\.([[:space:]]|;|$)'; then
  deny "git 不可逆操作を遮断。ユーザー承認後に手動実行してください"
fi

# 秘密ファイルのコマンド経由読み出し（Read deny の Bash 迂回を塞ぐ）
# .env.example / .env.sample / .env.template / .env.dist は秘密を含まないため除外
if echo "$CMD" | grep -Eq '(cat|head|tail|less|more|strings|cp|base64|xxd|grep)[[:space:]][^|;&]*(\.env[^[:space:]]*|\.clasprc|\.railway/|id_rsa|id_ed25519|\.ssh/|\.aws/|\.gnupg/|credentials\.json|service-account[^[:space:]]*\.json|\.npmrc|\.git-credentials|[^[:space:]]+\.pem($|[[:space:]])|[^[:space:]]+\.key($|[[:space:]]))'; then
  if ! echo "$CMD" | grep -Eq '\.env\.(example|sample|template|dist)'; then
    deny "秘密ファイルのコマンド経由読み出しを遮断"
  fi
fi

# 秘密情報の外部送信疑い（送信系コマンド + 秘密名。先頭/区切りアンカーと token= 形で誤検知を抑制）
if echo "$CMD" | grep -Eq '(^|[;&|`]|[[:space:]]|\$\()(curl|wget|scp|sftp|ftp|rsync|nc|ncat|telnet)[[:space:]][^;&|]*(\.env([[:space:]./"'"'"']|$)|id_rsa|id_ed25519|\.aws/|\.ssh/|\.gnupg/|credentials\.json|service-account|secret[_-]?key|private[_-]?key|[_-]token[=[:space:]"'"'"']|api[_-]?key|access[_-]?key)'; then
  deny "秘密情報の外部送信の疑いを遮断"
fi

# スクリプト言語経由の秘密ファイルアクセス（誤爆が多いため deny でなく確認に落とす）
if echo "$CMD" | grep -Eq '(^|[;&|`]|[[:space:]]|\$\()(python3?|node|deno|bun|ruby|php)[[:space:]][^;&|]*(\.env([[:space:]./"'"'"']|$)|id_rsa|\.aws/|\.ssh/|credentials\.json|service-account|secret[_-]?key|private[_-]?key|api[_-]?key)'; then
  ask "スクリプトが秘密情報ファイルにアクセスしようとしています。送信先・用途を確認してください"
fi

exit 0
