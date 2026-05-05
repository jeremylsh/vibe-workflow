#!/usr/bin/env bash
set -euo pipefail

REPO="jeremylsh/vibe-workflow"
BRANCH="master"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

SKILLS=(
  "feat/SKILL.md"
  "git-commit/SKILL.md"
  "git-pr/SKILL.md"
  "git-tag/SKILL.md"
  "deploy/SKILL.md"
  "rollback/SKILL.md"
)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

info()  { echo -e "${GREEN}[vibe]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[vibe]${RESET} $*"; }
error() { echo -e "${RED}[vibe]${RESET} $*" >&2; }

# Resolve target directory
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)"

if [[ ! -d "${TARGET_DIR}/.git" ]]; then
  error "目标目录不是一个 git 仓库: ${TARGET_DIR}"
  echo ""
  echo "用法:"
  echo "  bash install.sh              # 安装到当前项目"
  echo "  bash install.sh /path/to/proj # 安装到指定项目"
  exit 1
fi

SKILLS_DIR="${TARGET_DIR}/.claude/skills"

info "安装 vibe-workflow skills 到 ${SKILLS_DIR}"

installed=0
updated=0
failed=0

for skill_path in "${SKILLS[@]}"; do
  skill_name="$(dirname "$skill_path")"
  dest="${SKILLS_DIR}/${skill_path}"
  url="${BASE_URL}/skills/${skill_path}"

  mkdir -p "$(dirname "$dest")"

  if [[ -f "$dest" ]]; then
    label="更新"
  else
    label="新增"
  fi

  http_code=$(curl -fsSL -w "%{http_code}" -o "$dest" "$url" 2>/dev/null) || http_code="000"

  if [[ "$http_code" == "200" ]]; then
    echo -e "  ${GREEN}✓${RESET} ${label} ${skill_name}"
    if [[ "$label" == "更新" ]]; then
      ((updated++))
    else
      ((installed++))
    fi
  else
    echo -e "  ${RED}✗${RESET} 下载失败 ${skill_name} (HTTP ${http_code})"
    rm -f "$dest"
    ((failed++))
  fi
done

echo ""
if [[ $failed -eq 0 ]]; then
  info "${installed} 个新增, ${updated} 个更新"
else
  error "${failed} 个失败, ${installed} 个新增, ${updated} 个更新"
  exit 1
fi
