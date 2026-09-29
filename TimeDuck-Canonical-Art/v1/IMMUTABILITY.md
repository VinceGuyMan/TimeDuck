# TimeDuck Canonical Art Immutability Guarantee
===============================================

The contents of this package (`TimeDuck-Canonical-Art/v1/`) represent the **permanently frozen canonical visual specification** of the TimeDuck desktop companion as of TimeDuck v1.2.0 (commit `0aca94357cd0f2a6475175a346087f5a5d72a0c5`).

## Immutability Rules

1. **Never Overwrite History**: Existing files within `v1/` must never be modified, replaced, or silently adjusted.
2. **Versioned Revisions**: If the TimeDuck production application introduces an intentional character redesign in future versions, a new version folder (e.g. `v2/`) must be created, and `CURRENT.md` updated.
3. **Cryptographic Sealing**: All files are hashed in `SHA256SUMS.txt`. Any discrepancy indicates unauthorized tampering.
