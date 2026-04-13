# API Performance Pro — Memory Index

## Session Context
- Memory files are stored in `.postqode/memory/`
- Read at session start, updated at key decision points

## Memory Files

| File | Created When | Content |
|---|---|---|
| `api_context.md` | After strategy | Endpoints, architecture, auth method, rate limits |
| `baseline_results.md` | After baseline | Pass/fail, error rate, p95 latency |
| `scale_results.md` | After scale-up | Max RPS, breaking point, bottleneck |
| `api_preferences.md` | User feedback | Tool choice, threshold overrides |

## Index
<!-- Updated automatically by the agent -->
