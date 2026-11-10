# HelpMeet landing page

Live at: https://jabaya7175-ai.github.io/helpmeet/ (once GitHub Pages is turned on)

## Files
- `index.html`: the landing page, connected to the Supabase waitlist.
- `privacy.html`: plain-language privacy page for the waitlist. Replace `[CONTACT EMAIL]` before sharing.
- `og.png`: the preview image shown when the link is shared in texts and social posts.
- `schema.sql`: the waitlist table and `join_waitlist()` function (already applied in Supabase), plus traction queries.
- `.github/workflows/keepalive.yml`: pings Supabase every 3 days so the free project doesn't pause.

## See sign-ups
Supabase dashboard → Table Editor → `waitlist`, or run the queries at the bottom of `schema.sql`.

## Track where people come from
Add `?src=` to links you share, e.g. `.../helpmeet/?src=grace-singles`. It's saved with each sign-up.
Invite links (`?ref=CODE`) are created automatically after someone joins.

## Custom domain later
Settings → Pages → Custom domain. Then update the two `og:` URLs at the top of `index.html`.
