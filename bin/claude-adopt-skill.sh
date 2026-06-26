#!/usr/bin/env bash
set -euo pipefail

# Adopt skills you built in ~/.claude/skills into this dotfiles repo so they get
# committed and synced to your other machines. Adopting moves the skill into the
# repo, symlinks it back, and whitelists it past the `.claude/skills/*` ignore.
# Run from the dotfiles repo root.
#
# Usage:
#   claude-adopt-skill.sh <name>   adopt one skill (any size)
#   claude-adopt-skill.sh --auto   adopt every un-adopted skill under the limits
#   claude-adopt-skill.sh          list un-adopted skills and suggest adopting

MAX_KB=5120     # 5 MB
MAX_FILES=100   # don't auto-vendor sprawling third-party skills

is_small() {    # dir -> true if under both limits
    local d="$1"
    [ "$(du -sk "$d" | cut -f1)" -lt "$MAX_KB" ] &&
    [ "$(find "$d" -type f -not -path '*/.git/*' | wc -l)" -lt "$MAX_FILES" ]
}

adopt_one() {
    local name="$1"
    local home_skill="${HOME}/.claude/skills/${name}"
    local repo_skill=".claude/skills/${name}"
    [ -e "$home_skill" ] || { echo "no such skill: $home_skill" >&2; return 1; }
    [ -L "$home_skill" ] && { echo "$name already adopted"; return 0; }
    [ -e "$repo_skill" ] && { echo "$repo_skill already exists in repo" >&2; return 1; }
    mkdir -p .claude/skills
    mv "$home_skill" "$repo_skill"
    rm -rf "${repo_skill}/.git"   # don't embed a nested git repo
    ln -s "$(realpath "$repo_skill")" "$home_skill"
    grep -qxF "!${repo_skill}/" .gitignore || printf '!%s/\n' "$repo_skill" >> .gitignore
    echo "adopted ${name} -> ${repo_skill}"
}

[ -f .gitignore ] || { echo "run this from the dotfiles repo root" >&2; exit 1; }

# Explicit single skill: adopt it regardless of size.
if [ "${1:-}" ] && [ "$1" != "--auto" ]; then
    adopt_one "$1"
    echo "next: git add .claude/skills/$1 .gitignore && git commit"
    exit 0
fi

# Scan un-adopted skills (real dirs, not already-adopted symlinks).
for d in "${HOME}"/.claude/skills/*/; do
    d="${d%/}"
    [ -d "$d" ] || continue
    [ -L "$d" ] && continue
    name="$(basename "$d")"
    if is_small "$d"; then
        if [ "${1:-}" = "--auto" ]; then
            adopt_one "$name"
        else
            echo "adoptable (<5MB, <100 files): $name   ->   bin/claude-adopt-skill.sh $name"
        fi
    fi
done
