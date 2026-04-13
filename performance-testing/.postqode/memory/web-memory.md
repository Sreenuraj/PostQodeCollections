# Web Performance Pro — Memory Index

## Session Context
- Memory files are stored in `.postqode/memory/`
- Read at session start, updated at key decision points
- Used to skip redundant questions, apply preferences, and reference past decisions

## Memory Files

| File | Created When | Content |
|---|---|---|
| `app_context.md` | After strategy phase | App type, tech stack, target URLs, intent |
| `baseline_results.md` | After baseline audit | Core Web Vitals pass/fail, key findings |
| `load_test_results.md` | After deep-dive | Max VUs, breaking point, bottleneck |
| `performance_preferences.md` | User gives feedback | Threshold overrides, tool preferences |

## Index
<!-- Updated automatically by the agent -->
