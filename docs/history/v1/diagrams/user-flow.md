# First Speaking User Journey

> Status: IN_PROGRESS
> Approved first-flow design inputs; conceptual behavior only, no runtime acceptance.

```mermaid
flowchart TD
  A[Brief coach introduction] --> B[Personal introduction prompt]
  B --> C[Record]
  C --> D[Replay]
  D -->|Try again| C
  D --> E{Online and wants AI feedback?}
  E -->|No| F[Self-review]
  E -->|Yes| G[Explicit audio ASR submission]
  G --> T[Review and confirm transcript]
  T --> U[Explicit confirmed-text coaching]
  U --> H{Validated feedback received?}
  H -->|No| I[Keep attempt; retry or self-review]
  I --> F
  H -->|Yes| J[Focused afterward feedback]
  J --> K[Optional vocabulary saving or retry]
  K --> Z[Finish and completion reward]
  F --> Z
  Z --> O[Optional saved baseline and later comparison]
```

First-session recording does not lock level. Improvement badges need evidence beyond participation. Other speaking modes are planned, not depicted as implemented screens.

## Introductions teaching and evaluation loop

Conceptual adopted flow; [INTRO-01](../product-specification/introductions-learning-loop.md) owns exact criteria. Optional baseline and delayed checks do not block core completion.

```mermaid
flowchart TD
  A[Offer optional independent baseline] --> B[Goal and reviewed listening/reading model]
  B --> C[Interleaved grammar and productive recall]
  C --> D[Guided introduction or quiet text practice]
  D --> E[Replay and self-review]
  E --> F{Request supported online feedback?}
  F -->|Yes| G[Confirm transcript and review focused actions]
  F -->|No or unavailable| H[Offline self-review]
  G --> I[Offer retry with less support]
  H --> I
  I --> J[Core completion after required attempts and review]
  J --> K[Later recall and reserved unfamiliar tasks]
  K --> L[Separate retention and transfer evidence]
  L --> M[Educator and owner expansion decision]
```

Assisted attempts remain practice; quiet completion does not establish speaking ability. Independent audio/text retention is optional throughout. See [IL protocol](../testing/introductions-learning-acceptance.md) for timing, support and pilot gates.

## Foundations within Learn

Conceptual adopted behavior; [English Foundations](../../../product-specification/english-foundations.md) owns scope and evidence rules.

```mermaid
flowchart LR
  A[Focused grammar in Learn] --> C[Shared foundation objective]
  B[CEFR lesson contextual refresher] --> C
  C --> D[Explain and practice]
  D --> E[Return to linked CEFR application]
  E --> F[Separate concept and use evidence]
```

Both paths preserve objective progress and originating lesson context. Foundations never become a mandatory level lock; first delivery includes only the reviewed Introductions subset.

## Course versus independent practice

Conceptual clarification from [course/practice requirements](../product-specification/learning-path-and-practice.md):

```mermaid
flowchart TD
  A[Learn CEFR course] --> B[Same reviewed training with any presenting coach]
  B --> C[Defined lesson completion and assessment]
  B -->|Explicit optional detour| D[Specialist practice]
  D -->|Return to saved position| B
  E[Speech Lab] --> D
  E --> F[Scoped AI conversation]
  E --> G[Scoped interview and follow-up]
  F --> H[Independent practice evidence]
  G --> H
  D --> H
  C --> I[Eligible local award commit]
  I --> J[Optional skippable celebration proposal]
```

Practice evidence cannot auto-complete the course or advance levels. Turn-based availability is distinct from deferred live voice capability; presentation/animation never grants the award.
