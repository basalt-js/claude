# Progress

Current: <M? → P?.? phase title> (next)
Last done: <P?.? phase title>, or "nothing yet"

<!--
Rules for writing this file:
- Rewrite it at every phase boundary. Never after every reply.
- Keep it to about one screen. It is read at the start of every session.
- "Current" and "Last done" must be the first two lines: hooks read them.
- If a session stops mid-phase, add a "Partial" section and keep "Current" on that phase.
- "Last done" names the phase, not a commit: the phase lands as a squash-merged PR whose
  commit hash isn't known yet. Its commit subject ends with the phase id, so git log finds it.
-->

## State

<Check command>: <passes | fails: what>. <Anything about the repo the next session should know.>

## Partial

<Only while a phase is unfinished: what's done, what's left, where to resume. Delete when the phase is done.>

## Decisions

- <decision> (<phase id>): <why, in one line>

## Blockers / waiting on you

- None

## Read first next time

- <path>: <why it matters for the next phase>
