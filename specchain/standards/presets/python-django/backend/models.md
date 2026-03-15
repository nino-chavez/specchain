# Model Standards (Django)

## Structure
- Abstract base models for shared fields (timestamps, soft-delete)
- Use UUIDs for public-facing IDs, keep auto-increment for internal PKs
- Add `__str__` to every model
- Define `Meta.ordering` explicitly

## Fields
- Use `TextField` with `max_length` validator instead of `CharField` for user content
- Use `DecimalField` for money (never `FloatField`)
- Add `db_index=True` on frequently queried fields
- Use `related_name` on all ForeignKey fields

## Migrations
- One migration per logical change
- Always include `reverse_code` for data migrations
- Test migrations both up and down
- Name migrations descriptively: `0003_add_user_email_verification`
