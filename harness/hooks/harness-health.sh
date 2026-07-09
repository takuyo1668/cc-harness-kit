#!/bin/bash
# SessionStart ハーネス健康チェック（警告のみ・自動削除はしない）
# MEMORY.md の肥大を検知してセッション冒頭に1行注意を出す。2026-06-10 監査で導入

# memory ディレクトリはプロジェクトごとにスラッグ化されたパス配下に作られるため、動的に探索する
# 例: ~/.claude/projects/<slug>/memory/MEMORY.md
MEM=$(find "$HOME/.claude/projects" -maxdepth 2 -name MEMORY.md 2>/dev/null | head -1)
[ -n "$MEM" ] && [ -f "$MEM" ] || exit 0

COUNT=$(grep -c '^- \[' "$MEM" 2>/dev/null || echo 0)
SIZE=$(wc -c < "$MEM" | tr -d ' ')

if [ "$COUNT" -gt 90 ] || [ "$SIZE" -gt 18000 ]; then
  echo "⚠️ MEMORY.md が ${COUNT}項目 / ${SIZE}B に肥大しています（目安: 90項目・18KB以下）。完了済みの古い conversation_log の整理を検討してください（インデックス行とファイルをセットで ~/.claude/archive/ へ）。"
fi
exit 0
