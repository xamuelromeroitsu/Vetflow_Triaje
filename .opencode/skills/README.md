# Agent Skills

Skills loaded automatically by opencode (`.opencode/skills/<name>/SKILL.md`).
Each one is only read when the task matches its `description`, so extra
references do not cost context until they are needed.

## Installed

| Skill | Covers | Use it when |
|---|---|---|
| `firebase-basics` | Firebase CLI: login, project selection, config files, `flutterfire` setup | Starting or switching Firebase projects |
| `firebase-auth-basics` | Firebase Authentication (Flutter) | Sign-in, users, `request.auth` in rules |
| `firebase-firestore` | Cloud Firestore **Standard** edition + Flutter SDK | Data model, queries, offline persistence, indexes |
| `firestore-rules-creation` | Writing `firestore.rules` | Authoring or modifying security rules |
| `firebase-security-rules-auditor` | Auditing rules for vulnerabilities | Reviewing rules before deploy |
| `architecture-patterns` | Clean / Hexagonal / Onion / DDD layering | Deciding module boundaries and dependency direction |

## Project notes

- The app is Flutter-only: SDK guides for Web, Android, iOS and Python were
  removed on purpose.
- Firestore edition is **Standard**; the Enterprise guides were removed. If a
  database ends up in Enterprise, fetch the official skills from
  https://github.com/firebase/agent-skills instead of writing Enterprise code
  from memory.
- Agent-environment setup guides (Claude Code, Cursor, Copilot, Gemini CLI,
  Antigravity, Android Studio) were removed to keep this repo agent-agnostic;
  the generic refresh guide stays at
  `firebase-basics/references/refresh/other-agents.md`.

## Updating

Re-install from the upstream repositories when needed:

```bash
npx skills add firebase/agent-skills
npx skills add wshobson/agents --skill architecture-patterns
```

Then re-apply the trims above.
