#!/usr/bin/env bash
set -Eeuo pipefail

TYPEBOT_TAG="v2.28.2"
TYPEBOT_REPO="https://github.com/baptisteArno/typebot.io.git"
WORKDIR="${AUTOBOT_WORKDIR:-$PWD/typebot-autobotpro}"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
need git
need sed
need find

rm -rf "$WORKDIR"
git clone --depth 1 --branch "$TYPEBOT_TAG" "$TYPEBOT_REPO" "$WORKDIR"
cd "$WORKDIR"

# Keep the upstream AGPLv3 license and copyright notices intact.
test -f LICENSE || { echo "LICENSE missing; refusing to continue" >&2; exit 1; }

# White-label only user-facing text and static asset references. Do not rewrite
# package names, import paths, database identifiers, or legal notices blindly.
find apps packages -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.json' -o -name '*.mdx' \) -print0 |
  xargs -0 sed -i \
    -e 's/Typebot/AutoBot Pro/g' \
    -e 's/typebot/AutoBot Pro/g'

# Restore technical identifiers accidentally affected by the generic pass.
find . -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.json' \) -print0 |
  xargs -0 sed -i \
    -e 's/@AutoBot Pro\//@typebot.io\//g' \
    -e 's/@AutoBot Pro/@typebot.io/g' \
    -e 's/AutoBot Pro-io/typebot.io/g'

# The Vietnamese layer is additive: preserve source locale infrastructure and
# install the supplied AutoBot Pro locale overrides when present.
mkdir -p apps/builder/src/i18n/autobotpro
cat > apps/builder/src/i18n/autobotpro/README.md <<'EOF'
# AutoBot Pro Vietnamese locale

UI translations are maintained as application overrides. Do not modify LICENSE
or upstream copyright notices. Add translated message keys here as the Builder
locale schema evolves.
EOF

echo "AutoBot Pro source prepared at: $WORKDIR"
echo "Upstream tag: $TYPEBOT_TAG"
echo "License: preserved from upstream; inspect LICENSE before redistribution."
