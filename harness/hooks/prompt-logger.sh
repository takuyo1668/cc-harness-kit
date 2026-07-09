#!/bin/bash
# UserPromptSubmit フック: ユーザーの全プロンプトを恒久記録する（プロンプトコーチング分析の一次データ）
# 出力先: ~/.claude/prompt-log/YYYY-MM.jsonl（1行 = {ts, session_id, cwd, prompt}）
# 設計: transcript(~/.claude/projects/)は約30日で自動削除されるため、フックで別ファイルに退避する
# 依存: python3 のみ（pretool-guard.sh と共通。jq不要）
# 実機テスト: echo '{"session_id":"test","cwd":"/tmp","prompt":"テスト"}' | prompt-logger.sh → prompt-log に1行追記
#
# 鉄則: 記録に失敗してもセッションを止めない（常に exit 0・stdout に何も出さない）

INPUT=$(cat)

LOGDIR="$HOME/.claude/prompt-log"
mkdir -p "$LOGDIR" 2>/dev/null && chmod 700 "$LOGDIR" 2>/dev/null

printf '%s' "$INPUT" | python3 -c '
import sys, json, os
from datetime import datetime, timezone
try:
    d = json.load(sys.stdin)
    prompt = d.get("prompt", "")
    if not isinstance(prompt, str) or prompt == "":
        sys.exit(0)
    rec = {
        "ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "session_id": d.get("session_id", ""),
        "cwd": d.get("cwd", ""),
        "prompt": prompt,
    }
    path = os.path.join(os.path.expanduser("~/.claude/prompt-log"),
                        datetime.now(timezone.utc).strftime("%Y-%m") + ".jsonl")
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")
    os.chmod(path, 0o600)
except Exception:
    pass
' 2>/dev/null

exit 0
