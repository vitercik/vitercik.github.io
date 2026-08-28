#!/usr/bin/env bash
set -euo pipefail

# Validate repository-owned metadata, including the site-specific Open Graph
# and ProfilePage/Person override of al_folio_core.

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
  unless config["serve_og_meta"] && config["serve_schema_org"]
    warn "Open Graph and ProfilePage/Person metadata must both remain enabled"
    exit 1
  end
  unless config["og_image"].to_s.start_with?("https://")
    warn "the selected Open Graph image must be an absolute HTTPS URL"
    exit 1
  end
  unless config["og_locale"] == "en_US" && config["og_image_alt"].to_s != ""
    warn "the Open Graph locale and image alternative text must be configured"
    exit 1
  end
  unless config.dig("schema_person", "id") == "https://vitercik.github.io/#person"
    warn "the Person identity must use the stable site-wide @id"
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
import json
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse


class MetadataParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.anchors = []
        self.canonical = []
        self.json_ld = []
        self.meta = {}
        self.title = []
        self._json_ld_chunks = None
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
        elif tag == "script" and values.get("type") == "application/ld+json":
            self._json_ld_chunks = []

    def handle_endtag(self, tag):
        if tag == "title" and self._title_chunks is not None:
            self.title.append("".join(self._title_chunks).strip())
            self._title_chunks = None
        elif tag == "script" and self._json_ld_chunks is not None:
            self.json_ld.append("".join(self._json_ld_chunks).strip())
            self._json_ld_chunks = None

    def handle_data(self, data):
        if self._title_chunks is not None:
            self._title_chunks.append(data)
        if self._json_ld_chunks is not None:
            self._json_ld_chunks.append(data)


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
    "research/index.html": (
        "/research/",
        "Summary of my research.",
    ),
    "bio/index.html": (
        "/bio/",
        "A short third-person biography.",
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
    "https://bsky.app/profile/ellen-v.bsky.social",
    "https://www.linkedin.com/in/vitercik",
    "https://twitter.com/vitercik",
}
structured_identity_links = {
    "https://profiles.stanford.edu/ellen-vitercik",
    "https://scholar.google.com/citations?user=6iUjvyMAAAAJ",
    "https://orcid.org/0000-0003-4891-1367",
    "https://dblp.org/pid/160/8900",
    "https://www.linkedin.com/in/vitercik",
    "https://x.com/vitercik",
    "https://bsky.app/profile/ellen-v.bsky.social",
}
research_topics = {
    "machine learning",
    "algorithm design",
    "discrete optimization",
    "combinatorial optimization",
    "algorithmic reasoning",
    "economics and computation",
}
home_anchors = []
home_schema = None

for relative_file, (path, description) in pages.items():
    output = site / relative_file
    require(output.is_file(), f"missing generated page: {relative_file}")
    parser = parse(output)
    canonical = f"{base_url}{path}"

    require(parser.meta.get("description") == [description], f"incorrect description: {path}")
    require(parser.canonical == [canonical], f"incorrect canonical URL: {path}")
    require(len(parser.title) == 1, f"expected one title: {path}")
    require(parser.title[0].count("Ellen Vitercik") == 1, f"duplicated or missing name in title: {path}")

    expected_type = "profile" if path == "/" else "website"
    expected_rich_metadata = {
        "og:site_name": "Ellen Vitercik",
        "og:type": expected_type,
        "og:title": parser.title[0],
        "og:url": canonical,
        "og:description": description,
        "og:image": f"{base_url}/assets/img/prof_pic.jpg",
        "og:image:type": "image/jpeg",
        "og:image:width": "1500",
        "og:image:height": "1500",
        "og:image:alt": "Portrait of Ellen Vitercik",
        "og:locale": "en_US",
        "twitter:card": "summary",
        "twitter:title": parser.title[0],
        "twitter:description": description,
        "twitter:image": f"{base_url}/assets/img/prof_pic.jpg",
        "twitter:image:alt": "Portrait of Ellen Vitercik",
        "twitter:site": "@vitercik",
        "twitter:creator": "@vitercik",
    }
    for key, value in expected_rich_metadata.items():
        require(parser.meta.get(key) == [value], f"incorrect {key}: {path}")

    if path == "/":
        require(parser.meta.get("profile:first_name") == ["Ellen"], "incorrect profile:first_name")
        require(parser.meta.get("profile:last_name") == ["Vitercik"], "incorrect profile:last_name")
        require(len(parser.json_ld) == 1, "homepage must contain one JSON-LD graph")
        home_schema = json.loads(parser.json_ld[0])
    else:
        require("profile:first_name" not in parser.meta, f"unexpected profile metadata: {path}")
        require(not parser.json_ld, f"only the homepage should emit Person JSON-LD: {path}")

    verify_link_policy(parser, path)

    if path == "/":
        home_anchors = parser.anchors

require(home_schema is not None, "homepage ProfilePage/Person graph was not parsed")
require(home_schema.get("@context") == "https://schema.org", "incorrect JSON-LD context")
graph = home_schema.get("@graph", [])
require(len(graph) == 2, "homepage JSON-LD graph must contain ProfilePage and Person nodes")
profile_page = next((node for node in graph if node.get("@type") == "ProfilePage"), None)
person = next((node for node in graph if node.get("@type") == "Person"), None)
require(profile_page is not None, "homepage JSON-LD is missing ProfilePage")
require(person is not None, "homepage JSON-LD is missing Person")
require(profile_page.get("@id") == f"{base_url}/#profile-page", "incorrect ProfilePage @id")
require(profile_page.get("url") == f"{base_url}/", "incorrect ProfilePage URL")
require(profile_page.get("name") == "Ellen Vitercik", "incorrect ProfilePage name")
require(profile_page.get("mainEntity") == {"@id": f"{base_url}/#person"}, "incorrect ProfilePage mainEntity")
require(person.get("@id") == f"{base_url}/#person", "incorrect Person @id")
require(person.get("name") == "Ellen Vitercik", "incorrect Person name")
require(person.get("givenName") == "Ellen", "incorrect Person givenName")
require(person.get("familyName") == "Vitercik", "incorrect Person familyName")
require(person.get("url") == f"{base_url}/", "incorrect Person URL")
require(person.get("image") == f"{base_url}/assets/img/prof_pic.jpg", "incorrect Person image")
require(person.get("jobTitle") == "Assistant Professor", "incorrect Person job title")
require(
    person.get("worksFor")
    == {
        "@type": "CollegeOrUniversity",
        "@id": "https://www.stanford.edu/#organization",
        "name": "Stanford University",
        "url": "https://www.stanford.edu/",
    },
    "incorrect Person affiliation",
)
require(set(person.get("sameAs", [])) == structured_identity_links, "incorrect Person sameAs identities")
require(set(person.get("knowsAbout", [])) == research_topics, "incorrect Person knowsAbout topics")

home_links = {anchor.get("href", "") for anchor in home_anchors}
require(required_identity_links <= home_links, "homepage is missing a verified identity link")
for identity_link in required_identity_links:
    matching_anchors = [anchor for anchor in home_anchors if anchor.get("href") == identity_link]
    require(
        all("nofollow" not in anchor.get("rel", "").split() for anchor in matching_anchors),
        f"verified identity link is marked nofollow: {identity_link}",
    )

home_html = (site / "index.html").read_text(encoding="utf-8")
selected_titles = (
    "How Much Data Is Sufficient to Learn High-performing Algorithms?",
    "Algorithms with Calibrated Machine Learning Predictions",
    "EquivaMap: Leveraging LLMs for Automatic Equivalence Checking of Optimization Formulations",
    "Can LLMs Reason Structurally? Benchmarking via the Lens of Data Structures",
    "Leveraging Reviews: Learning to Price with Buyer and Seller Uncertainty",
)
for title in selected_titles:
    require(home_html.count(title) == 1, f"homepage must include the selected publication exactly once: {title}")

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
