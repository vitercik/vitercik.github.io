#!/usr/bin/env bash
set -euo pipefail

# Guard the production build against publishing or embedding starter demo
# content. The deterministic integration override disables external fetching,
# while the configuration check below ensures production does the same.

tmp_dir="$(mktemp -d)"
site="${tmp_dir}/site"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

ruby -rpsych -e '
  load_file = if Psych.respond_to?(:unsafe_load_file)
                Psych.method(:unsafe_load_file)
              else
                Psych.method(:load_file)
              end
  config = load_file.call("_config.yml") || {}
  sources = config["external_sources"]
  unless sources.nil? || (sources.is_a?(Array) && sources.empty?)
    warn "_config.yml external_sources must be empty for the production site"
    exit 1
  end
  if config["blog_name"].to_s.strip == "al-folio"
    warn "_config.yml must not use the starter blog name"
    exit 1
  end
  if config["blog_description"].to_s.strip == "a simple whitespace theme for academics"
    warn "_config.yml must not use the starter blog description"
    exit 1
  end
'

vertical_tab_matches="$(
  LC_ALL=C grep -rIl $'\v' \
    _bibliography _books _config.yml _data _news _pages _posts _teachings awards \
    2>/dev/null || true
)"
if [ -n "${vertical_tab_matches}" ]; then
  echo "ASCII vertical-tab byte found in site source:" >&2
  printf '%s\n' "${vertical_tab_matches}" >&2
  exit 1
fi

JEKYLL_ENV=production bundle exec jekyll build \
  --config "_config.yml,test/integration-test-config.yml" -d "${site}" >/dev/null

for required_file in index.html publications/index.html robots.txt sitemap.xml; do
  if [ ! -f "${site}/${required_file}" ]; then
    echo "expected production output is missing: ${required_file}" >&2
    exit 1
  fi
done

if ! grep -q '^User-agent: \*$' "${site}/robots.txt"; then
  echo "robots.txt must include the wildcard user agent" >&2
  exit 1
fi
if ! grep -q '^Disallow:[[:space:]]*$' "${site}/robots.txt"; then
  echo "robots.txt must allow public crawling" >&2
  exit 1
fi
if ! grep -q '^Sitemap: https://vitercik.github.io/sitemap.xml$' "${site}/robots.txt"; then
  echo "robots.txt must advertise the production sitemap URL" >&2
  exit 1
fi

while IFS= read -r phrase; do
  [ -n "${phrase}" ] || continue
  matches="$(
    find "${site}" -type f \( \
      -name '*.html' -o \
      -name '*.xml' -o \
      -name '*.json' -o \
      -name '*.js' -o \
      -name '*.txt' \
    \) -exec grep -lF "${phrase}" {} + 2>/dev/null || true
  )"
  if [ -n "${matches}" ]; then
    echo "starter demo phrase found in production output: ${phrase}" >&2
    printf '%s\n' "${matches}" >&2
    exit 1
  fi
done <<'PHRASES'
The Godfather
Albert Einstein
einstein@example.com
A simple inline announcement
A long announcement with details
Displaying External Posts on Your al-folio Blog
Google Gemini updates: Flash 1.5, Gemma 2 and Project Astra
Data Science Fundamentals
Introduction to Machine Learning
a post with image galleries
a post with plotly.js
a simple whitespace theme for academics
PHRASES

while IFS= read -r relative_directory; do
  [ -n "${relative_directory}" ] || continue
  if [ -e "${site}/${relative_directory}" ]; then
    echo "starter demo route family was generated: /${relative_directory}/" >&2
    exit 1
  fi
  if grep -qF "/${relative_directory}/" "${site}/sitemap.xml"; then
    echo "starter demo route family is present in sitemap.xml: /${relative_directory}/" >&2
    exit 1
  fi
done <<'ROUTE_FAMILIES'
blog
books
plugins
teachings
_pages/dropdown
ROUTE_FAMILIES

while IFS= read -r relative_file; do
  [ -n "${relative_file}" ] || continue
  if [ -e "${site}/${relative_file}" ]; then
    echo "non-site repository file was published: /${relative_file}" >&2
    exit 1
  fi
done <<'FORBIDDEN_FILES'
AGENTS.md
CLAUDE.md
requirements.txt
test/integration_site_hygiene.sh
assets/pdf/example_pdf.pdf
assets/audio/epicaly-short-113909.mp3
assets/bibliography/2018-12-22-distill.bib
assets/html/relativity.html
assets/img/book_covers/the_godfather.jpg
assets/img/prof_pic_color.png
assets/img/publication_preview/brownian-motion.gif
assets/img/publication_preview/wave-mechanics.gif
assets/json/resume.json
assets/jupyter/blog.ipynb.html
assets/plotly/demo.html
assets/rendercv/rendercv_output/Albert_Einstein_CV.pdf
assets/video/pexels-engin-akyurt-6069112-960x540-30fps.mp4
assets/video/tutorial_al_folio.mp4
FORBIDDEN_FILES

echo "production site hygiene checks passed"
