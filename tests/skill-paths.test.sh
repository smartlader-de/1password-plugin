#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)

[ -d "$package_root/skills/environments" ] || { echo "FAIL: skills/environments/ missing"; exit 1; }
[ -f "$package_root/skills/environments/SKILL.md" ] || { echo "FAIL: skills/environments/SKILL.md missing"; exit 1; }
[ -d "$package_root/skills/ssh-git" ] || { echo "FAIL: skills/ssh-git/ missing"; exit 1; }
[ -f "$package_root/skills/ssh-git/SKILL.md" ] || { echo "FAIL: skills/ssh-git/SKILL.md missing"; exit 1; }
[ -d "$package_root/skills/vaults-items" ] || { echo "FAIL: skills/vaults-items/ missing"; exit 1; }
[ -f "$package_root/skills/vaults-items/SKILL.md" ] || { echo "FAIL: skills/vaults-items/SKILL.md missing"; exit 1; }
[ -d "$package_root/skills/setup" ] || { echo "FAIL: skills/setup/ missing"; exit 1; }
[ -f "$package_root/skills/setup/SKILL.md" ] || { echo "FAIL: skills/setup/SKILL.md missing"; exit 1; }
[ -f "$package_root/references/vercel.md" ] || { echo "FAIL: references/vercel.md missing"; exit 1; }

for ref in docs-map items-vaults secret-references service-accounts-connect sdks environments-transfer shell-plugins local-env-mount; do
  [ -f "$package_root/references/$ref.md" ] || { echo "FAIL: references/$ref.md missing"; exit 1; }
done

# Reference paths mentioned in nested skills must exist relative to the skill dir.
for skill in environments vaults-items ssh-git setup; do
  grep -o '\.\./\.\./references/[a-z-]*\.md' "$package_root/skills/$skill/SKILL.md" | sort -u | while read -r rel; do
    [ -f "$package_root/skills/$skill/$rel" ] || { echo "FAIL: $skill references missing file $rel"; exit 1; }
  done
done

echo "PASS: skill paths valid"
