# Doctorly / Disha Supabase Security Policy Audit

## RLS Policies

| Table | Policy Name | Operation | Target Roles | Using / With Check | Notes |
|-------|-------------|-----------|--------------|-------------------|-------|
| doctors | doctors read public | SELECT | anon, authenticated | `using (data_status = 'published' AND verification_status IN ('verified', 'partially_verified'))` | Public directory catalog; excludes draft, in_review, rejected, and test fixture records. |
| services | services read public | SELECT | anon, authenticated | `using (true)` | Open lookup table of healthcare services / subspecialties. |
| doctor_services | doctor_services read public | SELECT | anon, authenticated | `using (EXISTS (SELECT 1 FROM doctors WHERE id = doctor_id AND data_status = 'published' AND verification_status IN ('verified', 'partially_verified')))` | Only permits reading service links for publicly published doctors. |
| favorites | favorites read own | SELECT | authenticated | `using (auth.uid() = user_id)` | Users read their own favorites only |
| favorites | favorites insert own | INSERT | authenticated | `with check (auth.uid() = user_id)` | Users can only insert rows for themselves |
| favorites | favorites delete own | DELETE | authenticated | `using (auth.uid() = user_id)` | Users can only delete their own favorites |
| appointments | appointments read own | SELECT | authenticated | `using (auth.uid() = user_id)` | Users read their own appointments only |
| appointments | appointments insert own | INSERT | authenticated | `with check (auth.uid() = user_id)` | Users can only insert rows for themselves |
| appointments | appointments update own | UPDATE | authenticated | `using (auth.uid() = user_id)` | Users can only update their own appointments |
| appointments | appointments delete own | DELETE | authenticated | `using (auth.uid() = user_id)` | Users can only delete their own appointments |
| reports | reports insert own | INSERT | authenticated, anon | `with check (auth.uid() = reporter_id)` | Users insert doctor reports |
| reports | reports select own | SELECT | authenticated, anon | `using (auth.uid() = reporter_id)` | Users inspect their own reports |
| doctor_reviews | Users can insert own doctor reviews | INSERT | authenticated | `with check (auth.uid() = user_id)` | Authenticated users post reviews |
| doctor_reviews | Anyone can read doctor reviews | SELECT | authenticated, anon | `using (true)` | Public reviews |

## Findings & Data Isolation

1. **Tightened SELECT on `doctors`** — Previous `using (true)` policy replaced by `data_status = 'published' AND verification_status IN ('verified', 'partially_verified')`.
   - **Test Fixture Isolation**: Any dummy dataset imported with `data_status = 'test'` (such as `docs/data/doctorly_test_data.tsv`) is strictly hidden from `anon` and `authenticated` roles.
   - **Verification Gating**: Doctors with `verification_status = 'unverified'` are never visible to the public or client apps.
2. **`doctor_services` Protection** — Scoped to match the doctor's published and verified status to prevent leaking metadata about unverified or test profiles.
3. **All write operations on `favorites` and `appointments` remain strictly scoped** to `auth.uid() = user_id`.

## Threat Model

- **Anonymous Read** — An unauthenticated user can only read verified, published doctor catalog rows and related services. `data_status = 'test'` or draft profiles cannot be scraped.
- **Service Role Writes** — The Import CLI and administrative tooling require the `service_role` key (bypassing RLS) to insert and upsert test datasets or bulk directory updates.
- **Client Security** — RLS is the single source of truth; no unverified or test record can escape to the client app regardless of client query filters.
