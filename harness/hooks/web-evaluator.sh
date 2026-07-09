#!/bin/bash
# Visual Evaluator フック
# HTML/CSS/JSファイルの変更を検知し、視覚検証を指示する

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# HTML/CSS/JSファイルのみ対象
if echo "$FILE_PATH" | grep -qE '\.(html|css|js|tsx|jsx)$'; then
  DIR=$(dirname "$FILE_PATH")
  # index.htmlまたはNext.js系のページファイルがあるか確認
  if [ -f "$DIR/index.html" ] || echo "$FILE_PATH" | grep -qE '\.(tsx|jsx)$'; then
    cat <<EOJSON
{
  "hookSpecificOutput": {
    "additionalContext": "【Visual Evaluator】Web成果物の変更を検知しました。以下の手順で視覚検証を実行してください:\n1. ローカルサーバーを起動（未起動の場合）\n2. ブラウザでスクリーンショットを撮影（Claude_Preview / Claude_in_Chrome MCP利用可能な場合）、または目視確認をユーザーに依頼\n3. 検証可能な合格基準（レイアウト崩れ・文字重なり・余白異常・コントラスト不足がない）に照らしてPASS/FIXを判定\n4. FIXの場合は修正して再検証（最大3回まで。3回超えたらユーザーにエスカレート）"
  }
}
EOJSON
  fi
fi
