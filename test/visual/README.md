# Personal-site browser checks

Run `npm run test:visual` after installing the Ruby dependencies, Node dependencies,
and Playwright Chromium/WebKit browsers. The command builds the production site at
the root URL and serves `_site` locally. It does not publish draft demo pages.

The suite checks the site's actual pages in desktop Chromium and mobile WebKit,
with light and dark preferences. It covers responsive layout, the portrait,
navigation, theme persistence, publication filtering, and awards filtering.
Screenshots are attached to the HTML report at `output/playwright/report/index.html`;
CI uploads the report, screenshots, and failure traces as `visual-site-report`.
Review the screenshots when changing theme dependencies or layout. They are review
artifacts, not automatically approved pixel baselines.

To test an already-built site, serve its output directory and set
`NO_WEBSERVER=1 VISUAL_BASE_URL=http://127.0.0.1:4000` when running the suite. This is
also useful for capturing reports from both the base branch and a candidate update.
Keep those reports in separate directories before the next run replaces them.

Upstream demo-page and v0.16.3 pixel-parity checks do not apply to this customized
site. Distill and other optional plugin behavior remain covered by their focused
integration scripts under `test/`.
