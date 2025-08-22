#!/usr/bin/env bash
set -euo pipefail

mkdir -p thecube-docs/{_data,assets/{images,css,js},getting-started,core,apps/built-in,api/schemas,hardware,thecube-plus,sdk,cloud,design,tutorials,community,.github/workflows}

cat > thecube-docs/CNAME <<'EOF'
docs.4thecube.com
EOF

cat > thecube-docs/_config.yml <<'EOF'
# (paste the _config.yml from above)
EOF

cat > thecube-docs/Gemfile <<'EOF'
# (paste the Gemfile from above)
EOF

cat > thecube-docs/.gitignore <<'EOF'
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata
vendor/
EOF

cat > thecube-docs/.github/workflows/pages.yml <<'EOF'
# (paste the Actions workflow from above)
EOF

cat > thecube-docs/_data/navigation.yml <<'EOF'
# (paste the navigation.yml from above or omit to use nav_order)
EOF

cat > thecube-docs/assets/css/custom.scss <<'EOF'
/* (paste the custom.scss from above) */
EOF

cat > thecube-docs/assets/js/custom.js <<'EOF'
/* (paste the custom.js from above) */
EOF

cat > thecube-docs/assets/images/logo.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" role="img" aria-label="TheCube">
  <rect x="16" y="16" width="96" height="96" rx="16" fill="#6c4bd6"/>
  <circle cx="48" cy="56" r="6" fill="#fff"/>
  <circle cx="80" cy="56" r="6" fill="#fff"/>
  <rect x="48" y="76" width="32" height="6" rx="3" fill="#fff"/>
</svg>
EOF

# Minimal placeholder writer
write_page () {
  path="$1"; title="$2"; desc="$3"
  cat > "thecube-docs/$path" <<EOF
---
title: $title
description: $desc
layout: default
---
# $title

> Placeholder. Replace with real content.
EOF
}

write_page "index.md" "Companion, TheCube" "Official documentation for TheCube." 

# Getting started
write_page "getting-started/index.md" "Overview" "What TheCube is and how to use these docs."
write_page "getting-started/install.md" "Install" "Set up hardware/software and local docs preview."
write_page "getting-started/quickstart.md" "Quickstart" "Power up, pair, and say hello."
write_page "getting-started/faq.md" "FAQ" "Common questions and answers."

# Core
for p in index architecture boot-sequence lifecycle event-bus config logging security performance; do
  write_page "core/$p.md" "$(tr '-' ' ' <<< $p | sed 's/.*/\L&/; s/^./\U&/')" "Core: $p"
done

# Apps (+ built-in)
for p in index app-model permissions notifications ui-guidelines lifecycle example-hello-app; do
  write_page "apps/$p.md" "$(tr '-' ' ' <<< $p | sed 's/.*/\L&/; s/^./\U&/')" "Apps: $p"
done
for p in index productivity communication health games; do
  write_page "apps/built-in/$p.md" "Built-in: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "Built-in apps: $p"
done

# API
for p in index rest websocket events; do
  write_page "api/$p.md" "API: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "API $p"
done
write_page "api/schemas/index.md" "API Schemas" "Event and payload schemas."

# Hardware
for p in index specs sensors gpio expansion disassembly compliance; do
  write_page "hardware/$p.md" "Hardware: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "Hardware $p"
done

# TheCube+
for p in index overview auth pricing quotas self-hosting api; do
  write_page "thecube-plus/$p.md" "TheCube+: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "TheCube+ $p"
done

# SDK
for p in index setup cli python javascript cpp testing publishing; do
  write_page "sdk/$p.md" "SDK: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "SDK $p"
done

# Cloud
for p in index architecture ops data-privacy; do
  write_page "cloud/$p.md" "Cloud: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "Cloud $p"
done

# Design
for p in index characters personality ux; do
  write_page "design/$p.md" "Design: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "Design $p"
done

# Tutorials
for p in index build-first-app add-presence-sensor home-assistant stream-deck retro-games 3d-topper; do
  write_page "tutorials/$p.md" "Tutorial: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "Tutorial $p"
done

# Community
for p in index contributing code-of-conduct changelog roadmap support troubleshooting releases glossary contact; do
  write_page "community/$p.md" "Community: $(tr '-' ' ' <<< $p | sed 's/^./\U&/')" "Community $p"
done

cat > thecube-docs/README.md <<'EOF'
# Companion, TheCube — Documentation
See `_config.yml` for theme and build settings. Local preview: `bundle install && bundle exec jekyll serve`
EOF

echo "Scaffold complete in ./thecube-docs"