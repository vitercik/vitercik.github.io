# Website Improvement Plan

**Status:** Phase 1 / PR 1 implemented and verified locally; deployment pending  
**Last updated:** 2026-08-25  
**Site:** <https://vitercik.github.io/>

## Objective

Improve the production website's accuracy, clarity, search visibility, and usefulness to researchers while preserving this repository's starter content, documentation, tests, and plugin ownership boundaries.

The required order is:

1. Clean the production output.
2. Improve identity, metadata, and homepage clarity.
3. Publish one strong research overview.
4. Add richer project or paper content selectively.
5. Measure before expanding further.

## Non-goals

- Do not redesign the entire site.
- Do not edit `_site`, generated search JavaScript, or the `gh-pages` branch.
- Do not add thin topic pages or abstract-only paper pages for search purposes.
- Do not add `llms.txt` or special "AI SEO" markup to the critical path.
- Do not patch shared runtime behavior locally when it belongs in an owning plugin.
- Do not delete documentation or test fixtures merely because they contain sample text.

## Timeline and release structure

| Phase    | Deliverable                                | Estimated effort                         | Release gate                                      |
| -------- | ------------------------------------------ | ---------------------------------------- | ------------------------------------------------- |
| 0        | Baseline and editorial decisions           | 0.5–1 day                                | Public URL list and research positioning approved |
| 1 / PR 1 | Production hygiene                         | 1–2 developer days                       | Zero demo content in the production build         |
| 2 / PR 2 | Metadata, identity, and homepage           | 1–2 developer days plus editorial review | Metadata and schema validated                     |
| 3 / PR 3 | Research overview and selected works       | 1–2 weeks elapsed                        | Ellen approves all research claims                |
| 4 / PR 4 | Two pilot project pages and flagship talks | 1–2 weeks elapsed                        | Content adds value beyond paper abstracts         |
| 5        | Measurement and selective expansion        | 8–12 weeks                               | Evidence supports further expansion               |

## Phase 0: Baseline and decisions

This phase can run in parallel with Phase 1.

### Capture the current state

- [ ] Save the current homepage and publications-page HTML.
- [ ] Save the current `robots.txt` and `sitemap.xml`.
- [ ] Capture the embedded site-search records from representative pages.
- [ ] Record the source and deployed commit identifiers.
- [ ] Create a production URL inventory with:
  - URL and source file
  - Keep, retire, or undecided
  - HTTP status
  - Sitemap presence
  - Indexability and canonical URL
  - Title, description, and H1
  - Structured-data type
- [ ] Confirm whether a Google Search Console URL-prefix property already exists for `https://vitercik.github.io/`.
- [ ] Export the longest available Search Console history, ideally including 28-day, 90-day, and 16-month views.
- [ ] Separate branded and non-branded queries where data volume permits.

### Decisions requiring Ellen's approval

- [ ] Confirm whether `/blog/`, `/books/`, `/plugins/`, and the dropdown demo page should be public. The default recommendation is no.
- [ ] Approve one umbrella research statement.
- [ ] Approve three or four research-theme labels.
- [ ] Decide whether economics and computation should remain prominent.
- [ ] Select four to six representative publications:
  - At least one established signature contribution
  - Several recent works showing current direction
  - Coverage across distinct parts of the research program
- [ ] Provide verified Stanford, Google Scholar, ORCID, and DBLP URLs.
- [ ] Decide whether GitHub and Semantic Scholar should be displayed.
- [ ] Decide how much personal material should remain on the homepage.
- [ ] Decide whether GPTBot may crawl the site for potential model training. This is independent of ChatGPT search inclusion through OAI-SearchBot.
- [ ] Decide whether to add analytics after considering privacy and maintenance needs.

### Phase 0 deliverable

Create a short facts and positioning brief containing:

- Exact appointment wording
- Approved research statement and themes
- Canonical short biography
- Selected publications
- Maintained identity links
- Claims and supporting sources
- A list of pages and external profiles Ellen controls

## Phase 1 / PR 1: Production hygiene

This release should contain no substantive research-copy changes.

### 1. Add a production-hygiene regression test

Create `test/integration_site_hygiene.sh` and invoke it from [`.github/workflows/unit-tests.yml`](../.github/workflows/unit-tests.yml).

The test should build the production site into a temporary directory and fail if:

- A known demo phrase appears in rendered HTML or embedded site-search data.
- A forbidden demo URL appears in `sitemap.xml`.
- A retired page is generated.
- A URL outside the approved production inventory appears in the sitemap.
- `robots.txt` does not point to the production sitemap.
- An ASCII vertical-tab byte (`0x0B`) remains in source content.
- A required production URL is missing.

Known demo strings should include:

- `The Godfather`
- `A simple inline announcement`
- `Displaying External Posts on Your al-folio Blog`
- `Data Science Fundamentals`
- `Introduction to Machine Learning`
- `a post with image galleries`
- `a post with plotly.js`
- `a simple whitespace theme for academics`

Update CI path filters so changes under `_books/`, `_news/`, `_teachings/`, and `robots.txt` run the relevant unit and visual checks.

### 2. Suppress production demo sources

Preferred first implementation:

- Mark fixture-only pages and collection items `published: false`.
- Configure the visual-test server to include unpublished fixtures with Jekyll's `--unpublished` option.
- Keep sample source and documentation available for starter and regression-test purposes.

Scope:

- `_books/the_godfather.md`
- `_news/announcement_1.md`
- `_news/announcement_2.md`
- `_news/announcement_3.md`
- `_posts/2024-12-04-photo-gallery.md`
- `_posts/2025-03-26-plotly.md`
- `_teachings/data-science-fundamentals.md`
- `_teachings/introduction-to-machine-learning.md`
- `_pages/books.md`
- `_pages/blog.md`
- `_pages/dropdown.md`
- `_pages/plugins.md`, unless intentionally retained as a public page

The photo-gallery page is a visual-test fixture, so its test coverage must remain functional after it is unpublished.

If maintainers require ordinary starter builds to show all sample pages, use a production-only configuration overlay instead. Prove the overlay's merge and exclusion behavior in a test before adopting it. Do not combine both suppression approaches unnecessarily.

### 3. Remove external sample ingestion

In [`_config.yml`](../_config.yml):

- Set `external_sources: []`.
- Remove or replace the generic al-folio blog name and description.
- Disable unused post and book archives if empty archive pages remain in the production build.
- Remove the misspelled `_pages/blod.md` exclusion and manage `blog.md` explicitly.
- Retain legitimate pages such as `/awards/`.

Do not use `noindex`, `robots.txt`, or hidden navigation as the primary cleanup mechanism. Those options do not necessarily remove demo records embedded in other indexed pages.

### 4. Remove orphaned static demo and development artifacts

The production build should also exclude static files that are unrelated to Ellen but would otherwise remain publicly addressable, including:

- The Albert Einstein sample resume, portrait, RenderCV output, and relativity page
- The Godfather cover
- The sample Jupyter blog notebook and Plotly demo
- The example PDF and sample Distill bibliography
- Starter-only audio and video assets
- Repository test scripts, agent instructions, and build requirements

Disable the unused sample `jekyll_get_json`/`jsonresume` configuration while the HTML CV page remains excluded. Preserve these assets in source where they are still useful as starter examples; the requirement is that they are absent from the production output.

### 5. Preserve repository ownership boundaries

Do not edit:

- `_site`
- `gh-pages`
- Generated JavaScript or embedded search records
- Plugin-owned layouts or includes

If unpublished or excluded source content still appears in generated search data, route the reusable fix to `al_search`. Follow [`docs/BOUNDARIES.md`](BOUNDARIES.md) for all runtime changes.

### PR 1 acceptance criteria

- [ ] Zero known demo strings in built HTML and embedded search data.
- [ ] Zero demo URLs in the generated sitemap.
- [ ] Orphaned Albert Einstein, Godfather, blog-demo, and development artifacts are absent from production output.
- [ ] Retired URLs return 404 after deployment.
- [ ] All approved production URLs remain reachable.
- [ ] Internal links from core pages are valid.
- [ ] Starter visual tests still exercise their fixtures and pass.
- [ ] No generated or deployment-branch files were edited.
- [ ] A clean deployment removes stale output.

## Phase 2 / PR 2: Metadata, identity, and homepage quality

### 1. Improve page descriptions

Replace the generic site description in [`_config.yml`](../_config.yml). Add concise, natural, page-specific descriptions to:

- Homepage
- Publications
- Biography
- Group
- Talks
- Teaching
- Tutorials
- Research, once the page exists

Keep navigation-facing frontmatter titles concise. Do not paste long SEO titles into `page.title`, because that value also controls headings and navigation labels.

### 2. Enable and validate built-in metadata

In [`_config.yml`](../_config.yml):

- Set `serve_og_meta: true`.
- Set `serve_schema_org: true`.
- Select and approve a site-wide Open Graph image.

Inspect the rendered output before adding any custom schema:

- Homepage facts match the visible copy.
- Canonical URLs are correct.
- A single consistent Person identity is emitted.
- Open Graph title, description, image, and URL are correct.
- There are no duplicate or conflicting Person objects.

If generic `WebSite`, ProfilePage, Person, or separate SEO-title support is missing, route the reusable improvement to `al_folio_core`. Avoid a starter-local head override.

### 3. Improve scholarly identity links

Add verified values to [`_data/socials.yml`](../_data/socials.yml):

- Stanford profile
- Google Scholar
- ORCID
- DBLP
- GitHub, if actively maintained
- Semantic Scholar, only if verified and useful

Navbar social links are already enabled. Leave `social: false` in [`_pages/about.md`](../_pages/about.md) unless Ellen also wants a second social block at the bottom of the homepage.

### 4. Fix visible technical-quality issues

- Replace the vertical-tab bytes in [`_pages/tutorials.md`](../_pages/tutorials.md) with intentional spaces or Markdown line breaks.
- Provide concise profile-image alt text, such as `Ellen Vitercik`.
- If explicit profile alt text is not supported, route the generic capability to `al_folio_core`.
- Change the global external-link relationship from `external nofollow noopener` to `external noopener` so trusted scholarly and institutional links do not receive blanket `nofollow`.

### 5. Revise the homepage

Recommended information order:

1. Name and exact Stanford appointments
2. Two- or three-sentence research statement
3. Link to the research overview
4. Four to six selected works
5. Background and honors
6. Personal notes

The opening should distinguish long-term identity from recent work. It should not imply that formal verification defines the entire research program.

### PR 2 acceptance criteria

- [ ] Every core page has an accurate, distinct description.
- [ ] Navigation labels remain short.
- [ ] No duplicated name appears in rendered titles.
- [ ] Canonical, Open Graph, and JSON-LD output parses correctly.
- [ ] Schema facts agree with visible content.
- [ ] Scholarly links resolve to the correct profiles.
- [ ] No `0x0B` bytes remain.
- [ ] Trusted scholarly links are not marked `nofollow`.
- [ ] The homepage role and research identity are clear within the first 100 words.

## Phase 3 / PR 3: Research overview and selected works

Create `_pages/research.md` with a `/research/` permalink. Do not create four separate topic pages at this stage.

### Suggested research-page structure

- Short overview of the research program
- Three or four Ellen-approved themes, potentially:
  - Data-driven algorithm design and discrete optimization
  - Algorithms with predictions and online decision-making
  - Neural and LLM-based algorithmic reasoning
  - Economics and computation
- Two to four representative works per theme
- Relevant talks, tutorials, courses, code, and videos
- Concise current-directions section
- A last-substantively-updated date

Target 700–1,200 words, including roughly 100–180 words of original explanation per theme.

### Selected-work process

In [`_bibliography/papers.bib`](../_bibliography/papers.bib):

- Add `selected={true}` to four to six approved entries.
- Include at least one established signature contribution.
- Include recent work that signals current direction.
- Balance themes rather than selecting only by recency or venue prestige.
- Prefer work with useful supporting materials.
- Credit coauthors accurately.

Only after entries are selected, set `selected_papers: true` in [`_pages/about.md`](../_pages/about.md).

Prepare a one-sentence explanation for each featured work covering:

- The problem
- Principal contribution
- Why the work matters
- Paper or project link

### PR 3 acceptance criteria

- [ ] Ellen approves every contribution and significance claim.
- [ ] The page reads as a coherent research program, not a keyword list.
- [ ] Established work and recent directions are distinguished.
- [ ] Every section links to relevant publications or supporting material.
- [ ] The publications page remains the complete scholarly record.
- [ ] No abstract is copied as a substitute for original explanation.
- [ ] Research is reachable from the homepage in one click.
- [ ] No unsupported `first`, `best`, or `state of the art` claim appears.

## Phase 4 / PR 4: Pilot richer content

### Two project or paper explainers

Create only two initial explainers:

- One established signature contribution
- One recent project with strong supporting assets

Each page should contain 500–900 words of original explanation:

- Exact title, authors, and venue
- Short summary
- Problem and approach
- Main result
- Why the result matters
- Scope and limitations
- Relationship to the broader research program
- Paper, code, slides, video, data, and BibTeX links where available
- Related research theme
- Optional figure with meaningful alt text

The page must add information beyond the paper abstract and remain useful even if it receives no search traffic.

### Flagship talks and tutorials

Enrich approximately five items with:

- A one- or two-sentence abstract
- Exact venue and year
- Clear labels for slides, recording, notes, and tutorial website
- Links to related papers and research themes
- Intended audience and learning outcomes for tutorials

Pilot a transcript or edited notes for at most one especially valuable talk. Do not commit to transcribing the complete archive.

### Reusable biography kit

Prepare approved versions for future profiles and events:

- One-sentence research description
- 40–50 word biography
- 90–120 word biography
- 150–200 word biography
- Canonical appointment wording
- Approved headshot and caption
- Identity-link pack

Use consistent facts and terminology without mechanically repeating identical phrases across every external profile.

### PR 4 acceptance criteria

- [ ] Each explainer adds original value beyond an abstract.
- [ ] Authors, venues, dates, and links match authoritative sources.
- [ ] Claims and attribution are reviewed by Ellen and, where appropriate, coauthors.
- [ ] Limitations are represented accurately.
- [ ] Featured talks and tutorials contain explanatory prose.
- [ ] Every featured item links to related research or publications.

## Phase 5: Measurement and decision gates

### Immediately after PR 1

- [ ] Confirm retired pages return 404.
- [ ] Confirm the live sitemap and embedded search data are clean.
- [ ] Submit the cleaned sitemap through Google Search Console.
- [ ] Use URL Inspection for the homepage, publications, awards, the research page once published, and one retired demo URL.
- [ ] Record a dated deployment annotation.

### Review cadence

- **2–7 days:** Verify live output, URLs, schema, and crawlability.
- **2–4 weeks:** Confirm that core pages have been recrawled and metadata is appearing.
- **8–12 weeks:** Compare rolling 28-day and 90-day Search Console trends.
- **Quarterly:** Optionally run a fixed qualitative LLM prompt benchmark.
- **6–9 months:** Review Google Scholar coverage only if paper metadata or hosting changed.

### Primary measures

- Intended indexed URLs divided by submitted intended URLs
- Google clicks and impressions to the homepage, research, and publications pages
- Non-branded research impressions where volume permits
- Demo-free branded snippets
- CTR for stable page/query groups
- Zero broken core links
- Zero critical structured-data errors
- No material Core Web Vitals regression

Average position and one-off search or LLM answers are diagnostic observations, not primary success metrics.

### Optional LLM benchmark

If used, define 10–15 fixed research/discovery prompts and run each three times per platform, quarterly at most. Record:

- Date, locale, model, and whether search was enabled
- Cited URLs
- Identity errors
- Unsupported factual claims

Report raw counts, such as `prompt runs citing an intended page / total prompt runs`, rather than presenting an alleged universal ranking.

### Gate for separate topic pages

Split a research theme into its own page only when it has:

- Enough unique material for a substantial page
- At least three relevant papers or resources
- Evidence of independent query interest or repeated audience demand
- A named maintainer

### Gate for more paper pages

Expand beyond the two pilots only when:

- Ellen or collaborators can maintain accurate original content.
- Existing pages are indexed and useful to visitors.
- Search Console, referrals, or repeated audience questions show demand.
- New pages will add more than copied abstracts and metadata.

## Bot-control policy

| Purpose                                     | Control                               | Recommendation                                 |
| ------------------------------------------- | ------------------------------------- | ---------------------------------------------- |
| Google Search and Google AI search features | Googlebot and Search Console settings | Keep crawlable and included                    |
| ChatGPT search inclusion                    | OAI-SearchBot                         | Allow                                          |
| Potential OpenAI model training             | GPTBot                                | Make a separate owner decision                 |
| User-triggered ChatGPT visits               | ChatGPT-User                          | Do not treat as the search-eligibility control |
| LLM discovery through `llms.txt`            | No documented eligibility control     | Defer                                          |

## Ownership routing

| Change                                                                                                     | Owner                                              |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| Site content, page descriptions, social data, bibliography selections, configuration, tests, and workflows | This repository                                    |
| External-feed configuration                                                                                | This repository                                    |
| External-feed runtime behavior                                                                             | `al_ext_posts`                                     |
| Search collection filtering or unpublished content leakage                                                 | `al_search`                                        |
| Generic head output, separate SEO titles, profile alt support, and Person/ProfilePage schema               | `al_folio_core`                                    |
| Automatic paper-detail pages and reusable citation metadata                                                | `al_citations` / core                              |
| Sitemap generation behavior                                                                                | `jekyll-sitemap`; local configuration remains here |

Avoid local layouts or includes for generic runtime fixes. If a local override becomes unavoidable, run the upgrade override audit and review `.al-folio-overrides.yml` before committing it.

## Verification suite

Run the repository's validated checks, including:

```bash
npm ci
npm run lint:prettier
npm run lint:style-contract
bundle exec jekyll build --baseurl /al-folio
bash test/integration_site_hygiene.sh
bash test/integration_comments.sh
bash test/integration_plugin_toggles.sh
bash test/integration_distill.sh
bash test/integration_bootstrap_compat.sh
bash test/integration_upgrade_cli.sh
npm run test:visual
bundle exec al-folio upgrade audit
bundle exec al-folio upgrade overrides audit
```

The local system Ruby currently lacks the project-required Bundler 4.0.6. Full verification should therefore run in the repository's Docker environment or the CI environment matching Ruby 3.3.5 unless the required Bundler version is installed.

## Rollout and rollback

- Merge each phase separately.
- Preview and approve the generated site before each production deployment.
- Verify the live site after each deployment before starting the next phase.
- Keep demo source assets during the first suppression rollout; consider permanent cleanup only after production output and tests are verified.
- Roll back a regression by reverting the relevant pull request and allowing the normal workflow to rebuild the site.
- Never patch or force-push `gh-pages`.
- Use `search_enabled: false` only as temporary containment if demo leakage unexpectedly survives source suppression.

Rollback is appropriate for broken legitimate URLs, false content, conflicting schema, misleading metadata, or other technical regressions. Flat traffic alone is not a sufficient rollback reason for a small academic site.

## Progress checklist

- [ ] Phase 0 baseline captured
- [ ] Ellen decisions recorded
- [x] PR 1 production hygiene implemented
- [ ] PR 1 deployed and verified
- [ ] PR 2 metadata and identity implemented
- [ ] PR 2 deployed and verified
- [ ] PR 3 research overview implemented
- [ ] PR 3 deployed and verified
- [ ] PR 4 pilot content implemented
- [ ] First 30-day review completed
- [ ] First 90-day review completed
- [ ] Expansion decision recorded
