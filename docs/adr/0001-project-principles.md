# ADR 0001 - Founding principles of the project

## State

Accepted

## Context

The project was born from an Arch machine already used and modified over time.
There is therefore a high risk of:

- replicate historical errors;
- carry useless packages with you;
- lose the logic of choices;
- depend on configurations you don't understand.

## Decision

These principles are adopted:

1. `Allowlist first`
   Only what is explicitly approved is replicated.

2. `Documentation is part of the product`
Documentation, ADR and teaching notes are not optional extras.

3. `Official repos first`
   AUR is the exception, not the rule.

4. `Didactic over clever`
   Simple, readable scripts are better than overly smart automations.

5. `Git before complexity`
Everything must be tracked and versioned.

6. `One decision at a time`
   The great architectural choices must be made in order, not all together.

## Consequences

- The project will grow in phases.
- Each phase will have clear deliverables.
- The final configurations must be able to be modified manually by Daniel.
- The technical choices will be explained as if to a student.
