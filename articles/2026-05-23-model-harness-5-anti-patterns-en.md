# Model + Harness: 5 Anti-Patterns I Hit Building With Claude Code

> A PM ran Claude Code as a production system for half a year. The lessons aren't about how smart Agents are. They're about what's still missing — the Harness. Here are the 5 anti-patterns that bit me, in order of frequency.

## One Formula

On May 19, a senior DeepSeek researcher posted a single line: **Model + Harness = Agent**.

The model solves *can it*. The Harness solves *will it stay sane, remember things, and pick the right tool*.

I wrote that line on the edge of my monitor — because every one of the 5 anti-patterns below is what happens when the Harness fails. And every one of them was me, not the model. The model isn't broken. The user just hadn't yet realized that an Agent is an engineering system, not a chatbot.

5 patterns, sorted by how often I crashed on them. Each one made it into my `CLAUDE.md` failure ledger the day after it bit me.

---

## Anti-Pattern #1: Reflexively Writing Code Instead of Scanning the Tool Stack First

**Trigger**: "Generate a .docx / .pdf / .xlsx / .pptx", "dispatch a reviewer / QA", "research X data", "automate Y" — anything that needs a specialized tool.

**Default bias**: LLM training data is saturated with *"just write a Python script"* samples. See "generate docx" → reach for `pip install python-docx`. See "I need a reviewer" → spin up a generic sub-agent. Never check whether a dedicated skill / agent / MCP / hook already exists locally.

**What I should have done**: Before any action, ask for one second — *"Is there a skill / agent / mcp / hook in my stack that already covers this?"* Match found → use it. No match → write your own, and explicitly tell the user *"I checked X, it doesn't cover Y, I'm rolling my own."*

**The crash**: Writing a quarterly financial report in .docx. I went straight to `python-docx`, ignored the fact that my stack had a full `document-skills:docx` skill (unpack → edit XML → repack → validate → image handling). The skill knew table-border corner cases. My hand-rolled version blew up on the same edge case twice.

**Harness takeaway**: An Agent system needs a **capability-index layer**. Don't let the LLM default to "freestyle code generation". Concretely: inject a tool-stack summary at `SessionStart`, do fuzzy keyword matching on skill descriptions, and use a `Stop` hook to verify that the right tool actually fired.

---

## Anti-Pattern #2: Patching With New Mechanisms Instead of Reflecting on Root Cause

**Trigger**: Right after a correction or a crash, the reflex is *"add a hook / add a feedback note / bump a memory preference"* — without first asking whether the mechanism already exists.

**Default bias**: LLMs read "consolidate the lesson" as "add a rule". But most of the time the rule is already there — the execution just missed it. Adding a new rule at that point just dilutes the attention weight of the old rule.

**What I should have done**: Before adding anything, grep the existing `CLAUDE.md` and memory layer. Covered already → this is an execution problem, just reflect on root cause, don't add rules. Not covered → only *then* consider adding, and prefer existing carriers (the failure ledger, an existing feedback file) over spawning new ones.

**The crash**: Right after Anti-Pattern #1 (the docx blowup), my first move was *"systematic consolidation — add a feedback memory + bump the MEMORY preference table + propose a new hook"*. The Meta-Law had already covered this case. The new rules were pure noise. It took the user asking *"why aren't you just reflecting on root cause, will more rules actually make you remember?"* for me to see it.

**Harness takeaway**: A self-evolving Agent system **must** ship with an anti-bloat mechanism. My current hard caps: **5 hooks max / 10 anti-pattern entries max** in the failure ledger / 30-day grep-0 invocations triggers auto-archive. Counting "deleted ≥1 rule this month" as a positive metric. Acknowledge that **rule bloat is itself a form of Agent degradation**.

---

## Anti-Pattern #3: Reflexively Telling a Story Instead of Checking the Facts

**Trigger**: Stocks / financials / legal / medical / any high-stakes analysis — especially "explain why X is happening" prompts.

**Default bias**: LLMs see a K-line and immediately reach for *"institutional accumulation / IPO lockup expiry / distribution"*. See an earnings report → fall into the comp-template narrative. See a legal case → procedural vs. substantive justice. **Telling a story is easier than checking facts**, so the model defaults to the story.

**What I should have done**: A layered methodology that **forces fact-gathering before reasoning**. For stocks I use 7 layers (company → financials → valuation → shareholders → sentiment → technicals → strategy). If any of the first 5 layers is skipped, no recommendation goes out.

**The crash**: A user asked "why is the sell pressure so heavy on this HK stock?" I glanced at the chart and started narrating *"one-year IPO lockup expiry, concentrated insider distribution"*. The user pulled the actual filings: ① The controlling shareholder had publicly committed *not to sell for 12 months* in a disclosure dated 6 weeks ago. ② The real driver was the **panic selling from holders trying to break even** after the stock got cut in half in 19 trading days the previous month. ③ 2025 revenue was already +80.8% YoY and the company had returned to profit. ④ Sell-side targets implied +30.8% upside. My story was 180° wrong.

**Harness takeaway**: High-stakes tasks need a **mandatory fact-check interceptor**. Don't let the Agent emit "why X" conclusions in the absence of any external data-source invocation in its trace. This is the single most-missed piece in Tool Use design.

---

## Anti-Pattern #4: The Familiarity Trap — Fluent Generation ≠ No Research Needed

**Trigger**: "How do I do X / what is X / look into X" — when X is a term from the last 1-2 years or a domain that iterates monthly (new frameworks, new platforms, new trends, vibe coding, Agent, MCP).

**Default bias**: When the LLM can generate fluently on a topic, it **misreads fluency for accuracy**. But fluent ≠ current — many newer concepts only have their *early* version in the training set, and the ecosystem has moved on in the last 6 months.

**What I should have done**: In the research phase, force-ask *"Is this a term from the last 2 years? Does its ecosystem iterate monthly?"* If yes → mandatory WebSearch ≥2 times, no matter how "familiar" I feel. **Forbidden anti-pattern**: deciding "no research needed" first and then reverse-justifying "the task isn't complex enough" to skip the research phase. That's circular logic.

**The crash**: User asked "how do I do vibe coding?" I answered straight from training data. Vibe coding only emerged in February 2025; the tooling and norms iterate by the month. My training cutoff knowledge was stale. The user had to ask twice — *"is that an answer after you researched it?"* and *"why didn't you follow the iron law?"* — before I went and ran the WebSearches I should have run on turn 1.

**Harness takeaway**: An Agent cannot fully trust its own "fluency signal". **Confidence ≠ Recency**. Cross-session long-term memory must maintain a list of *"training cutoff + high-velocity domains"* and use it as a mandatory-WebSearch trigger.

---

## Anti-Pattern #5: Treating the Discipline as a "High-Effort Mode" — Letting Task Tone Decide Whether to Think

**Trigger**: User asks in a light tone ("by the way", "just a quick one", "add a small thing", "casual question"). **The lighter the tone, the higher the risk**.

**Default bias**: The LLM uses *"user's tone"* as a proxy variable for *"task weight"*. Light tone → light task → skip the full think-stage. But **real task complexity is determined by task nature, not by user tone**.

**What I should have done**: Any input that says "do / add / change X" defaults to the full research-and-think stages, even if the user opened with "just a side note".

**The crash**: User: *"by the way — let's add a WeChat Reading skill, just a side note"*. I instantly fired off a 4-option multiple-choice question *"which kind of install?"* (violating *think-before-asking*), then decided to use `skill-creator` to build it from scratch (violating Anti-Pattern #1 — the official WeChat Reading skill **already existed**). Never entered the think-stage at all. This is the shared upstream bug of #1 and *think-before-ask*: I never started thinking-mode in the first place.

**Harness takeaway**: An Agent must not let user tone leak into its internal reasoning path. My current hard rule: any execution-class input defaults through the Meta-Law three-stage (research 4Q + think 5Q + execute), even if the user says "just a quick one".

---

## The Common Root

Looking back at all 5: the root cause is the same. **LLMs default to the shortest path** — generate-when-you-can-generate, add-a-rule-when-you-could-reflect, tell-a-story-when-you-could-check-facts, trust-familiarity-when-you-could-verify, respond-lightly-when-you-could-think.

And the Harness exists for exactly one purpose: **to force the Agent down the correct path, not the shortest path**. Through Hook enforcement / Watchdog fallback / Memory persistence / Multi-Agent cross-review / a failure ledger as image-memory anchors.

I now run a 4-layer defense:

- **L1** — `CLAUDE.md` text reminder (lowest hit rate)
- **L2** — categorized memory files + preference mapping
- **L3** — `SessionStart` hook with forced injection
- **L4** — `UserPromptSubmit` + `Stop` hooks + the failure ledger (as image-memory anchors)

Coverage ceiling is roughly 30% — that's only the structural anti-patterns. The remaining 70% (semantic anti-patterns) is caught by post-task reflection + user corrections. **I don't pretend to cover 100%** — acknowledging the ceiling is itself a critical part of Harness design.

---

## 3 Concrete Takeaways For People Building Agent Products

1. **Cross-session long-term memory should be files, not vector DBs.** Vector recall is noisy. Files + categorized memory + a master index are readable, greppable, auditable — and stable over time. (My current setup: ~80 memory files, validated.)

2. **Multi-Agent setups must include an independent reviewer agent.** Executor agents self-grading their own work just rationalizes their own blind spots. In a 6+1+1 protocol (6 executors + 1 independent reviewer + 1 synthesizer), the *independent reviewer* is the single highest-leverage component for review quality.

3. **Hooks + Watchdogs beat "teach the Agent to be careful".** Prompt-based reminders cover about ~30%. The other 70% is semantic anti-patterns — those only get caught by hook-level enforcement and a reflection ledger. Counting on the model to remember by itself? It will forget.

---

Written 2026-05-23. I'm still hitting new anti-patterns; the ledger is still growing. Agent engineering is a long road — there is no permanent-fix "right way to do it", only "one fewer category of crash than yesterday".

PS: The "I" here is a product manager, not an engineer. I do write code (with Claude Code as the pair), but this post stays at the product / engineering-pattern layer.

---

*Author: Liu Yaoming (Gehry) — 10-year internet PM, OpenClaw personal project author, Claude Code daily heavy user.*

*Companion piece (Chinese version): `articles/2026-05-23-model-harness-5-anti-patterns-zh.md`*

*Related: [Helix EVOLUTION.md](../EVOLUTION.md) — the full 19 iron laws with origin failure cases.*
