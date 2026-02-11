# Workflow - Let's Stretch

## TDD Policy

**Moderate** - Tests are encouraged but will not block progress.

- Write tests for business logic, data models, and non-trivial algorithms
- UI code does not require tests unless it contains complex logic
- When fixing bugs, write a regression test first when practical
- Test coverage is a guide, not a gate

## Commit Strategy

**Squash per task** - One squashed commit per completed task.

- Each task produces a single, clean commit
- Commit message should summarize the task outcome
- Format: `[track-id] task description`
- Example: `[stretch-reminders] Add configurable reminder intervals`

## Code Review

**Optional / self-review OK** - This is a solo project.

- Self-review changes before committing
- Use `git diff` to review staged changes
- No PR approval required

## Verification Checkpoints

**Only at track completion** - Verify once when the entire feature track is done.

- At track completion, manually verify all acceptance criteria
- Run full test suite before marking a track complete
- Document any known issues or follow-ups

## Task Lifecycle

1. **Pending** - Task is defined but not started
2. **In Progress** - Actively being worked on
3. **Done** - Implementation complete, tests passing (if applicable)

## Branch Strategy

- `main` - Stable, working code
- `track/<track-id>` - Feature branches per track
- Merge to main after track completion and verification
