#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/comments-test-override.yml"
tmp_site="${tmp_dir}/site"
fixture_suffix="$$-${RANDOM}"
giscus_fixture="_posts/2000-01-01-comments-integration-giscus-${fixture_suffix}.md"
disqus_fixture="_posts/2000-01-02-comments-integration-disqus-${fixture_suffix}.md"

cleanup() {
  rm -f "${giscus_fixture}" "${disqus_fixture}"
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

cat >"${giscus_fixture}" <<'MARKDOWN'
---
layout: post
title: giscus comments integration fixture
date: 2000-01-01
permalink: /integration-test/comments/giscus/
giscus_comments: true
related_posts: false
---

Temporary fixture for the comments integration test.
MARKDOWN

cat >"${disqus_fixture}" <<'MARKDOWN'
---
layout: post
title: disqus comments integration fixture
date: 2000-01-02
permalink: /integration-test/comments/disqus/
disqus_comments: true
related_posts: false
---

Temporary fixture for the comments integration test.
MARKDOWN

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
YAML

bundle exec jekyll build --config "_config.yml,test/integration-test-config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

giscus_page="${tmp_site}/integration-test/comments/giscus/index.html"
disqus_page="${tmp_site}/integration-test/comments/disqus/index.html"

grep -q 'https://giscus.app/client.js' "${giscus_page}"
if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
  echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
  exit 1
fi

grep -q 'id="disqus_thread"' "${disqus_page}"
grep -q '.disqus.com/embed.js' "${disqus_page}"

echo "comments integration checks passed"
