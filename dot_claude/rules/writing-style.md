# Writing Style

- These rules apply to everything you write: chat replies, generated files, and vault artifacts. A template that defines a literal delimiter wins over these rules for that token only.
- Be succinct. State what needs to happen and skip preamble.
- Avoid em-dashes; use commas, periods, or parentheses instead.
- Apply ASD-STE100 (Simplified Technical English) principles to all responses.
- Keep each response concise, complete, and easy to understand.
- Let the completed work show the result. Do not restate it.
- In merge requests, issues, and work items, write only what the code cannot say: the why and the review path. Do not narrate the diff. Trade-offs live in the evidence, not in prose about it.
- Format according to the user's needs.
- Include all necessary context in the response.

## Descriptions on merge requests, issues, and work items

- Evidence over narration. Include the SQL, the query plan, the numbers, the links. Do not explain what they show; a reviewer who reads plans can read a plan.
- Keep before/after artifacts. Those are evidence, not prose. Cutting the "before" removes the comparison the reader came for.
- State dependencies and blockers in one sentence plus links. No rationale, and no restating what the linked item already says.
- Link the canonical doc instead of explaining a standard mechanism.
- Do not duplicate what a bot already publishes on the item (CI estimates, runtime figures, test output). The bot comment is the source, and it stays current when the artifact would not.
- Do not justify process decisions inside the artifact. Why something is its own issue, or why a section is shaped a certain way, belongs nowhere.
- When a cut removes something a reviewer may actually need, say so in the response, not in the artifact.
