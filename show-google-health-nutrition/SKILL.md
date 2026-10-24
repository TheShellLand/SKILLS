---
name: show-google-health-nutrition
description: Show daily Google Health nutrition progress with aligned bars, percentages, daily targets, and logged food sources. Use when the user asks for their nutrition report or nutrition progress.
---

# Show Google Health Nutrition

Create a daily nutrition report for the requested date, defaulting to today in the user's timezone. Use available Google Health records or data supplied by the user. If the records are unavailable, ask for the missing data rather than inventing intake, targets, or food sources.

## Nutrients and Data

Include:

- Protein and fiber.
- Water.
- All 13 essential vitamins: A, C, D, E, K, B1, B2, B3, B5, B6, B7, B9, and B12.
- Essential minerals, including calcium, iron, potassium, and sodium, plus other minerals available in the records.

Use the recorded daily target for each nutrient. Normalize intake and target to matching units before computing `intake / target × 100`. Use g for protein and fiber, mL or L for water, and mg or mcg for vitamins and minerals as appropriate to the recorded values.

Distinguish a recorded zero from missing data. Include vitamins with recorded zero intake as 0%; label unavailable values as unknown. If a target is missing or zero, show the available intake with an unknown percentage instead of dividing by zero or choosing a target.

## Report Format

Present the report as a Markdown bulleted list inside one plain-text code block so spacing stays aligned. State that there are 13 essential vitamins in a short introductory line within the block.

Sort nutrients by unrounded percentage from highest to lowest; put unknown percentages last. Display rounded whole-number percentages. Keep percentages above 100% visible.

Begin each nutrient's content with an eight-cell progress bar such as `[████░░░░]`, followed by percentage, nutrient name, and current intake / daily target. Align bars and columns using spaces. Fill the bar proportionally to the percentage, rounded to the nearest cell, capping the fill at eight cells. For unknown percentages, use `[????????]` and `N/A`.

Add indented food-source bullets directly below applicable nutrients. Include only logged sources and amounts available in the records. Omit nested bullets when no sources or only negligible sources are logged; do not infer a food's nutrient contribution from its name.

Illustrative rows (not user data):

```text
Daily nutrition — YYYY-MM-DD; includes all 13 essential vitamins.

- [████████] 120%  Vitamin C  108 / 90 mg
  - Logged food source: recorded contribution
- [████░░░░]  50%  Protein     30 / 60 g
- [░░░░░░░░]   0%  Vitamin D    0 / 15 mcg
- [????????]  N/A  Vitamin K  unknown / unknown
```

Best: include all 13 vitamins and preserve the difference between zero and unknown intake. Avoid: omitting zero-intake vitamins or fabricating targets to complete a progress bar.
