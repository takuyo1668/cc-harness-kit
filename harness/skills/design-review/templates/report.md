---
title: Design Review {{PROJECT}} {{DATE}}
date: {{DATE}}
tags: [design-review, {{PROJECT}}]
type: design-review
status: pending-feedback
target: {{TARGET_PATH}}
reviewers: [ui-specialist, product-designer, tech-researcher]
total_score: {{TOTAL_SCORE}}
issue_count:
  P0: {{P0_COUNT}}
  P1: {{P1_COUNT}}
  P2: {{P2_COUNT}}
---

# Design Review — {{PROJECT}} ({{DATE}})

## 🎯 統合サマリ

| 項目 | 値 |
|------|----|
| 対象 | `{{TARGET_PATH}}` |
| レビュー日 | {{DATE}} |
| 統合スコア | **{{TOTAL_SCORE}}/10** |
| P0（致命的） | {{P0_COUNT}}件 |
| P1（中程度） | {{P1_COUNT}}件 |
| P2（軽微） | {{P2_COUNT}}件 |

### 観点別スコア

| 観点 | スコア | レビュアー |
|------|--------|------------|
| UI品質 | {{UI_SCORE}}/10 | ui-specialist |
| 美的整合性（好み一致度） | {{AESTHETIC_SCORE}}/10 | ui-specialist |
| UX / 情報設計 | {{UX_SCORE}}/10 | product-designer |
| アクセシビリティ | {{A11Y_SCORE}}/10 | tech-researcher |

### 全体所感（1段落）

{{OVERALL_COMMENT}}

---

## 🔥 P0 — 致命的（即対応推奨）

{{P0_ISSUES_TABLE}}

<!-- フォーマット:
| # | 課題 | 該当箇所 | 改善案（検証可能） | 指摘元 | 好み参照 |
|---|------|----------|--------------------|--------|----------|
| 1 | CTAボタンのコントラスト比1.8（基準4.5） | line 42 / `bg-gray-300 text-white` | `bg-blue-600 text-white` でコントラスト比7.5に | tech-researcher | - |
-->

---

## ⚠️ P1 — 中程度（次回スプリントで対応推奨）

{{P1_ISSUES_TABLE}}

---

## 💡 P2 — 軽微（ポリッシュ）

{{P2_ISSUES_TABLE}}

---

## 📋 各レビュアーからの詳細所感

### ui-specialist より（UI品質・美的整合性）

{{UI_SPECIALIST_NOTES}}

### product-designer より（UX・情報設計）

{{PRODUCT_DESIGNER_NOTES}}

### tech-researcher より（アクセシビリティ）

{{TECH_RESEARCHER_NOTES}}

---

## 🧠 ユーザー好みプロファイル参照状況

このレビューで参照した `preferences.md` の項目:

{{PREFERENCES_USED}}

<!-- 例:
- ✅ 一致: 余白は section間 64px 以上を好む（line 30 が80pxで一致）
- ❌ 不一致: 色数3系統以内を好む（line 78 で5色使用検出）
- ➖ 該当なし: 角丸の三段階ルール
-->

このレビューで「不採用」とすべき指摘パターン（patterns.md から注入された除外項目）:

{{PATTERNS_EXCLUDED}}

---

## ✅ フィードバック収集ログ（Phase 4 で更新）

| 課題# | ユーザー判定 | 理由メモ |
|-------|--------------|----------|
{{FEEDBACK_TABLE}}

<!-- 例:
| P0-1 | 採用 | コントラスト比は確かにマズイ |
| P1-3 | 不採用 | ダークモード非対応で運用するのでこの指摘は不要 |
-->

---

## 🔄 蒸留結果（Phase 5 で更新）

### preferences.md への追記

{{PREFERENCES_UPDATES}}

### patterns.md への追記

{{PATTERNS_UPDATES}}

---

## 📎 関連

- 前回レビュー: {{PREVIOUS_REVIEW_LINK}}
- 対象プロジェクト: `{{PROJECT}}`
- preferences.md: `~/.claude/skills/design-review/preferences.md`
- patterns.md: `~/.claude/skills/design-review/patterns.md`
