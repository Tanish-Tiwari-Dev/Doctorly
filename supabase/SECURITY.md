# Doctorly Supabase Security Policy Audit

## RLS Policies

| Table | Policy Name | Operation | Target Roles | Using / With Check | Notes |
|-------|-------------|-----------|--------------|-------------------|-------|
| doctors | doctors read | SELECT | anon, authenticated | `using (true)` | Fully open read; public catalog |
| favorites | favorites read own | SELECT | authenticated | `using (auth.uid() = user_id)` | Users read their own favorites only |
| favorites | favorites insert own | INSERT | authenticated | `with check (auth.uid() = user_id)` | Users can only insert rows for themselves |
| favorites | favorites delete own | DELETE | authenticated | `using (auth.uid() = user_id)` | Users can only delete their own favorites |
| appointments | appointments read own | SELECT | authenticated | `using (auth.uid() = user_id)` | Users read their own appointments only |
| appointments | appointments insert own | INSERT | authenticated | `with check (auth.uid() = user_id)` | Users can only insert rows for themselves |
| appointments | appointments update own | UPDATE | authenticated | `using (auth.uid() = user_id)` | Users can only update their own appointments |
| appointments | appointments delete own | DELETE | authenticated | `using (auth.uid() = user_id)` | Users can only delete their own appointments |

## Findings

1. **Permissive SELECT on `doctors`** — `using (true)` allows anyone (including anon) to read all doctor rows. This is acceptable only because doctor profiles are treated as a **public catalog**. Do NOT add sensitive fields (e.g., phone, email) to `public.doctors` without tightening this policy.
2. **All write operations on `favorites` and `appointments` are correctly scoped** to `auth.uid() = user_id`. No `using (true)` write policies exist.
3. **RPC `nearby_doctors`** is granted to `anon, authenticated`. Because the underlying `doctors` SELECT policy is open, the RPC does not add additional auth risk. If `doctors` policy is tightened later, the RPC grant must be revisited.

## Threat Model

- **Anonymous read** — An unauthenticated user can list all doctors and run the nearby search. This is by design for discoverability. Risk: data scale exposure (scraping). Mitigation: keep only public-facing fields in `doctors`.
- **Authenticated write** — Authenticated users can only affect rows where `user_id` matches their auth UID. RLS is the source of truth; client-side checks are not trusted.
- **Privilege escalation** — No path for an anon user to write to `favorites` or `appointments`; all write policies require `authenticated`.
- **Data leakage** — `favorites` and `appointments` are fully isolated per user via RLS. Even if a user guesses another user's UUID, they cannot read or mutate those rows.

## Recommendations

- [ ] Keep `doctors` columns limited to public data.
- [ ] Migrate from anonymous auth to email/OTP + Google + Apple in Phase 8 to reduce abuse surface.
- [ ] Add rate limiting on `nearby_doctors` RPC if scraping becomes a concern (Phase 8+).
