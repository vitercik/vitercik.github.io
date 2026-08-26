#!/usr/bin/env bash
set -euo pipefail

# Validate repository-owned metadata while the richer Open Graph, Person, and
# profile-alt contracts remain blocked on al_folio_core.

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
  if config["serve_og_meta"] || config["serve_schema_org"]
    warn "built-in rich metadata must remain disabled until the al_folio_core contract is corrected"
    exit 1
  end
  unless config["og_image"].to_s.start_with?("https://")
    warn "the selected Open Graph image must be an absolute HTTPS URL"
    exit 1
  end
  if config.dig("external_links", "rel").to_s.split.include?("nofollow")
    warn "external_links.rel must not apply blanket nofollow"
    exit 1
  end
'

JEKYLL_ENV=production bundle exec jekyll build \
  --config "_config.yml,test/integration-test-config.yml" -d "${site}" >/dev/null

python3 - "${site}" <<'PY'
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse


class MetadataParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.anchors = []
        self.canonical = []
        self.meta = {}
        self.title = []
        self._title_chunks = None

    def handle_starttag(self, tag, attrs):
        values = dict(attrs)
        if tag == "meta":
            key = values.get("name") or values.get("property")
            if key:
                self.meta.setdefault(key, []).append(values.get("content", ""))
        elif tag == "link" and "canonical" in values.get("rel", "").split():
            self.canonical.append(values.get("href", ""))
        elif tag == "a":
            self.anchors.append(values)
        elif tag == "title":
            self._title_chunks = []

    def handle_endtag(self, tag):
        if tag == "title" and self._title_chunks is not None:
            self.title.append("".join(self._title_chunks).strip())
            self._title_chunks = None

    def handle_data(self, data):
        if self._title_chunks is not None:
            self._title_chunks.append(data)


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def parse(path):
    parser = MetadataParser()
    parser.feed(path.read_text(encoding="utf-8"))
    return parser


def verify_link_policy(parser, page_path):
    for anchor in parser.anchors:
        rel = anchor.get("rel", "").split()
        href = anchor.get("href", "")
        external = urlparse(href).scheme in {"http", "https"} and not href.startswith(
            "https://vitercik.github.io"
        )
        if external and anchor.get("target") == "_blank":
            require("noopener" in rel, f"external target=_blank link lacks noopener: {page_path}")


site = Path(sys.argv[1])
base_url = "https://vitercik.github.io"
pages = {
    "index.html": (
        "/",
        "Ellen Vitercik is an Assistant Professor at Stanford working on machine learning, algorithm design, discrete optimization, and economics and computation.",
    ),
    "publications/index.html": (
        "/publications/",
        "Publications in machine learning, algorithm design, discrete and combinatorial optimization, and economics and computation.",
    ),
    "bio/index.html": (
        "/bio/",
        "A short biography of Ellen Vitercik, Assistant Professor jointly appointed in Management Science and Engineering and Computer Science at Stanford.",
    ),
    "faq/index.html": (
        "/faq/",
        "Answers to common questions for Stanford students and prospective graduate students or postdocs interested in my teaching and research group.",
    ),
    "group/index.html": (
        "/group/",
        "Current and former PhD students and postdoctoral researchers in my research group at Stanford.",
    ),
    "talks/index.html": (
        "/talks/",
        "Recent research talks on machine learning, discrete optimization, combinatorial optimization, and algorithmic reasoning.",
    ),
    "teaching/index.html": (
        "/teaching/",
        "Stanford courses in probability, algorithms, machine learning, and discrete optimization.",
    ),
    "tutorials/index.html": (
        "/tutorials/",
        "Tutorials on machine learning for optimization and algorithm design, and automated mechanism design.",
    ),
}
required_identity_links = {
    "https://profiles.stanford.edu/ellen-vitercik",
    "https://github.com/vitercik",
    "https://www.linkedin.com/in/vitercik",
    "https://twitter.com/vitercik",
}
home_anchors = []

for relative_file, (path, description) in pages.items():
    output = site / relative_file
    require(output.is_file(), f"missing generated page: {relative_file}")
    output_html = output.read_text(encoding="utf-8")
    parser = parse(output)
    canonical = f"{base_url}{path}"

    require(parser.meta.get("description") == [description], f"incorrect description: {path}")
    require(parser.canonical == [canonical], f"incorrect canonical URL: {path}")
    require(len(parser.title) == 1, f"expected one title: {path}")
    require(parser.title[0].count("Ellen Vitercik") == 1, f"duplicated or missing name in title: {path}")
    require(not any(key.startswith("og:") for key in parser.meta), f"premature Open Graph output: {path}")
    require('type="application/ld+json"' not in output_html, f"premature JSON-LD output: {path}")
    verify_link_policy(parser, path)

    if path == "/":
        home_anchors = parser.anchors

home_links = {anchor.get("href", "") for anchor in home_anchors}
require(required_identity_links <= home_links, "homepage is missing a verified identity link")
for identity_link in required_identity_links:
    matching_anchors = [anchor for anchor in home_anchors if anchor.get("href") == identity_link]
    require(
        all("nofollow" not in anchor.get("rel", "").split() for anchor in matching_anchors),
        f"verified identity link is marked nofollow: {identity_link}",
    )

awards_description = (
    "A curated, regularly-updated list of paper competitions, dissertation awards, fellowships, and early-career "
    "awards for PhD students and postdocs in machine learning, operations research, theory, and optimization. "
    "Maintained by Ellen Vitercik's group at Stanford."
)
awards_title = "Awards for PhD Students & Postdocs — Vitercik Group, Stanford"
awards = parse(site / "awards/index.html")
require(awards.canonical == [f"{base_url}/awards/"], "incorrect awards canonical URL")
require(awards.meta.get("description") == [awards_description], "incorrect awards description")
require(awards.meta.get("og:site_name") == ["Ellen Vitercik"], "incorrect awards og:site_name")
require(awards.meta.get("og:type") == ["website"], "incorrect awards og:type")
require(awards.meta.get("og:title") == [awards_title], "incorrect awards og:title")
require(awards.meta.get("og:url") == [f"{base_url}/awards/"], "incorrect awards og:url")
require(awards.meta.get("og:description") == [awards_description], "incorrect awards og:description")
require(awards.meta.get("og:image") == [f"{base_url}/assets/img/prof_pic.jpg"], "incorrect awards og:image")
require(awards.meta.get("og:image:width") == ["1500"], "incorrect awards og:image:width")
require(awards.meta.get("og:image:height") == ["1500"], "incorrect awards og:image:height")
require(awards.meta.get("og:image:alt") == ["Portrait of Ellen Vitercik"], "incorrect awards og:image:alt")
require(awards.meta.get("og:locale") == ["en_US"], "incorrect awards og:locale")
require(awards.meta.get("twitter:card") == ["summary"], "incorrect awards Twitter card")
require(awards.meta.get("twitter:title") == [awards_title], "incorrect awards Twitter title")
require(awards.meta.get("twitter:description") == [awards_description], "incorrect awards Twitter description")
require(awards.meta.get("twitter:image") == [f"{base_url}/assets/img/prof_pic.jpg"], "incorrect awards Twitter image")
require(awards.meta.get("twitter:image:alt") == ["Portrait of Ellen Vitercik"], "incorrect awards Twitter image alt")
require((site / "assets/img/prof_pic.jpg").is_file(), "selected Open Graph image is missing from the production build")
verify_link_policy(awards, "/awards/")

print("production metadata checks passed")
PY
