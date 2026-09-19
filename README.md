# spd-paywall-live

Mobile-friendly **live status** for Desktop M6 paywall Tart E2E (GitHub Pages).

## Public URL

**https://david-vsco.github.io/spd-paywall-live/live.html**

Also: [status.json](https://david-vsco.github.io/spd-paywall-live/status.json)

## How it works

- `live.html` fetches `status.json` every **10s** (JS poll + `<meta refresh>` fallback).
- Fleet / paywall bots overwrite **only** `status.json` — no HTML rewrite needed.

## Schema (`status.json`)

```json
{
  "title": "Desktop M6 paywall — Tart E2E",
  "doing_now": "…",
  "next_up": "…",
  "updated_at": "2026-09-19T17:29:56Z",
  "machine": "hostname",
  "agent_url": "https://cursor.com/agents/…",
  "branch": "cursor/desktop-m6-paywall-cc24",
  "tickets": ["VPS-45858"],
  "checklist": [
    { "label": "Build / deps", "state": "done" },
    { "label": "Tart hard gate", "state": "doing" },
    { "label": "RESULT capture", "state": "todo" }
  ],
  "notes": "optional"
}
```

Checklist `state`: `done` | `doing` | `todo` | `blocked` | `fail` | `skipped`

**Do not put secrets** (tokens, keys, Stripe secrets) in this file — it is public.

## Update from a bot (~10–30s)

```bash
# edit / write status.json, then:
./publish-status.sh status.json
```

Or one-liner with `gh`:

```bash
SHA=$(gh api repos/david-vsco/spd-paywall-live/contents/status.json --jq .sha)
gh api -X PUT repos/david-vsco/spd-paywall-live/contents/status.json \
  -f message="chore: update paywall live status" \
  -f content="$(base64 < status.json | tr -d '\n')" \
  -f sha="$SHA" \
  -f branch=main
```

Git push alternative: clone this repo, replace `status.json`, `git commit && git push` to `main`.

Pages source: **main** branch `/` (root).
