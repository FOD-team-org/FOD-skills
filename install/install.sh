#!/usr/bin/env bash
# FOD-skills 설치 스크립트 (macOS·Linux·Git Bash)
#
# 사용법:
#   bash install/install.sh [claude|codex|both] [--dry-run] [--home <dir>] [--project <dir>]
#
#   claude|codex|both  스킬을 복사할 대상. 기본 both
#   --dry-run          무엇을 할지만 출력하고 아무것도 쓰지 않는다
#   --home <dir>       홈 경로 대신 쓸 폴더(테스트용). 주면 CODEX_HOME은 무시하고 <dir>/.codex를 쓴다
#   --project <dir>    그 폴더에 codex-dev 묶음(AGENTS.md, DECISIONS.md, ASSUMPTIONS.md)도 설치한다
#
# 스킬은 ~/.claude/skills/<name>, ${CODEX_HOME:-~/.codex}/skills/<name>에 복사한다.
# 같은 이름 폴더가 이미 있으면 덮어쓰지 않고 건너뛴다. 그 밖의 파일(설정·인증)은 건드리지 않는다.

set -eu

usage() {
  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
}

die() {
  echo "오류: $*" >&2
  exit 1
}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
SKILLS_SRC="$REPO_DIR/skills"
PACK_SRC="$REPO_DIR/packs/codex-dev"
MARKER="<!-- FOD-skills:codex-dev AGENTS.md -->"

TARGET="both"
DRY_RUN=0
HOME_DIR=""
PROJECT_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    claude|codex|both) TARGET="$1" ;;
    --target)
      [ $# -ge 2 ] || die "--target 뒤에 claude|codex|both 가 필요하다"
      case "$2" in claude|codex|both) TARGET="$2" ;; *) die "알 수 없는 대상: $2" ;; esac
      shift ;;
    --dry-run) DRY_RUN=1 ;;
    --home)
      [ $# -ge 2 ] || die "--home 뒤에 폴더가 필요하다"
      HOME_DIR="$2"; shift ;;
    --project)
      [ $# -ge 2 ] || die "--project 뒤에 폴더가 필요하다"
      PROJECT_DIR="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "알 수 없는 인자: $1 (--help 참고)" ;;
  esac
  shift
done

[ -d "$SKILLS_SRC" ] || die "skills 폴더가 없다: $SKILLS_SRC"

if [ -n "$HOME_DIR" ]; then
  [ -d "$HOME_DIR" ] || die "--home 폴더가 없다: $HOME_DIR"
  HOME_DIR=$(cd "$HOME_DIR" && pwd)
  CODEX_DIR="$HOME_DIR/.codex"
else
  HOME_DIR="${HOME:?HOME 이 비어 있다}"
  CODEX_DIR="${CODEX_HOME:-$HOME_DIR/.codex}"
fi

if [ -n "$PROJECT_DIR" ]; then
  [ -d "$PROJECT_DIR" ] || die "--project 폴더가 없다: $PROJECT_DIR"
  [ -d "$PACK_SRC" ] || die "묶음 폴더가 없다: $PACK_SRC"
  PROJECT_DIR=$(cd "$PROJECT_DIR" && pwd)
fi

DESTS=""
case "$TARGET" in
  claude) DESTS="$HOME_DIR/.claude/skills" ;;
  codex) DESTS="$CODEX_DIR/skills" ;;
  both) DESTS="$HOME_DIR/.claude/skills
$CODEX_DIR/skills" ;;
esac

INSTALLED=0
SKIPPED=0
PREFIX=""
[ "$DRY_RUN" -eq 1 ] && PREFIX="[미리보기] "

note_install() {
  INSTALLED=$((INSTALLED + 1))
  echo "${PREFIX}설치: $1"
}

note_skip() {
  SKIPPED=$((SKIPPED + 1))
  echo "${PREFIX}건너뜀(이미 있음): $1"
}

# 스킬 복사
OLD_IFS=$IFS
IFS='
'
for dest in $DESTS; do
  IFS=$OLD_IFS
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$dest"
  fi
  for src in "$SKILLS_SRC"/*/; do
    [ -f "${src}SKILL.md" ] || continue
    name=$(basename "$src")
    if [ -e "$dest/$name" ]; then
      note_skip "$dest/$name"
      continue
    fi
    if [ "$DRY_RUN" -eq 0 ]; then
      cp -R "${src%/}" "$dest/$name"
    fi
    note_install "$dest/$name"
  done
done
IFS=$OLD_IFS

# 프로젝트 묶음
if [ -n "$PROJECT_DIR" ]; then
  agents="$PROJECT_DIR/AGENTS.md"
  if [ -f "$agents" ] && grep -qF "$MARKER" "$agents"; then
    note_skip "$agents (codex-dev 규칙이 이미 붙어 있음)"
  elif [ -f "$agents" ]; then
    if [ "$DRY_RUN" -eq 0 ]; then
      {
        printf '\n%s\n' "$MARKER"
        cat "$PACK_SRC/AGENTS.md"
      } >> "$agents"
    fi
    note_install "$agents (기존 파일 끝에 이어 붙임)"
  else
    if [ "$DRY_RUN" -eq 0 ]; then
      {
        printf '%s\n' "$MARKER"
        cat "$PACK_SRC/AGENTS.md"
      } > "$agents"
    fi
    note_install "$agents (새로 만듦)"
  fi

  for tpl in DECISIONS.md ASSUMPTIONS.md; do
    if [ -e "$PROJECT_DIR/$tpl" ]; then
      note_skip "$PROJECT_DIR/$tpl"
      continue
    fi
    if [ "$DRY_RUN" -eq 0 ]; then
      cp "$PACK_SRC/templates/$tpl" "$PROJECT_DIR/$tpl"
    fi
    note_install "$PROJECT_DIR/$tpl"
  done
fi

[ "$DRY_RUN" -eq 1 ] && echo "[미리보기] 아무것도 쓰지 않았다. 아래 수는 실제로 돌렸을 때의 예상이다."
echo "설치 $INSTALLED / 건너뜀 $SKIPPED / 전체 $((INSTALLED + SKIPPED))"
