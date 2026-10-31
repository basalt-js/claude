# Plain-language arguments

Every `/basalt:*` command accepts plain words as well as its exact arguments (D7a). The user describes what they want; the command maps it onto its own arguments. Each command lists its exact form under "Arguments" and points here for the rules.

## How to read `$ARGUMENTS`

Decide which of three cases the text after the command is, in this order:

1. **Empty.** Do what the command documents for no arguments. Don't ask, and don't echo.
2. **Exact.** The text already matches the command's exact form, for example `/basalt:status M2`. Use it as given. Don't reinterpret it, and don't echo.
3. **Plain language.** Anything else. Map it onto the exact form, then:
   - **Clear and complete:** print one line, `Interpreting as: /basalt:<command> <exact arguments>`, and carry on.
   - **Clear, but a required value is missing:** echo what you could fill in, leaving the missing value out rather than padding it with the user's vague words, and ask only for that value.
   - **Fits more than one reading:** ask the user to pick one, with the most likely reading first.
   - **Doesn't fit this command:** say so, name the command that fits, and stop. Don't do the other command's work.

Print the `Interpreting as:` line as soon as you have read what you need to resolve the words (a phase title needs the roadmap), and before any of the command's own work. That way the user can stop a wrong reading early, and it shows them the exact form for next time. Free text that a command passes through, such as a note or a description, gets the echo unless the user put it in quotes.

## Asking

- Ask for the smallest missing piece, never for a restatement of the whole request.
- Use AskUserQuestion when the command has it, with the candidate readings as options, the recommended one first. Without it, ask in one short line and wait.
- Never invent a required value (a phase id, a description, a milestone) to avoid asking. A wrong guess costs more than one question.
- Ids are matched by meaning: "the plain-language phase" is the phase whose title says so, and "the mascot milestone" fits both M2 and M3 here, so it is a question.

## Plain language never skips a step

The mapped request runs the command's normal flow, with every approval in it:

- `plan` still shows the full draft and waits for approval before writing.
- `continue` still does one phase, and still asks before merging. Naming a phase other than `Current` changes the roadmap's order, so it needs the user's confirmation first.
- `status` stays read-only, whatever the words ask for.

Words in the arguments that would skip a step, such as "skip the review" or "don't show me the draft", are not arguments. Say so, and run the normal flow.
