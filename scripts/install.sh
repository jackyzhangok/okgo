#!/usr/bin/env bash
# okgo 技能安装/升级脚本：复制、校验、软链到已存在的工具目录，并打印调用方式。
# 用户不需要手工复制或解压。
#
# 用法：
#   bash scripts/install.sh                    # 安装到 ~/.agents/skills/okgo
#   bash scripts/install.sh ~/.dsh/skills/okgo # 自定义安装位置
#   bash scripts/install.sh --no-link          # 只安装，不建软链
#
# 环境变量：
#   OKGO_REPO_URL  从远程安装时使用的仓库地址（默认 GitHub）
set -euo pipefail

SKILL_NAME="okgo"
REPO_URL="${OKGO_REPO_URL:-https://github.com/jackyzhangok/okgo.git}"
LINK=1
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --no-link) LINK=0 ;;
    -h|--help)
      printf '%s\n' \
        "用法: bash scripts/install.sh [目标目录] [--no-link]" \
        "  默认安装到 ~/.agents/skills/okgo，并软链到已存在的工具技能目录。" \
        "  可用 OKGO_REPO_URL 覆盖仓库地址。" >&2
      exit 0 ;;
    -*) echo "未知参数：$arg" >&2; exit 2 ;;
    *) TARGET="$arg" ;;
  esac
done

TARGET="${TARGET:-$HOME/.agents/skills/$SKILL_NAME}"
TARGET="${TARGET%/}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$(cd "$script_dir/.." && pwd)"

tmp=""
cleanup() { [ -n "$tmp" ] && rm -rf "$tmp"; }
trap cleanup EXIT

# 1. 定位源：脚本在技能目录内就用本地文件，否则从仓库克隆
if [ ! -f "$src/SKILL.md" ]; then
  tmp="$(mktemp -d)"
  echo "→ 克隆 $REPO_URL"
  git clone --depth 1 --quiet "$REPO_URL" "$tmp/$SKILL_NAME"
  src="$tmp/$SKILL_NAME"
fi

if [ "$(cd "$src" && pwd)" = "$(cd "$TARGET" 2>/dev/null && pwd || true)" ]; then
  echo "· 目标就是源目录，跳过复制：$TARGET"
else
  # 2. 安装（覆盖更新；保留目标里的 .git 与 dist）
  mkdir -p "$TARGET"
  for item in SKILL.md readme.md references assets scripts; do
    [ -e "$src/$item" ] || continue
    rm -rf "$TARGET/$item"
    cp -R "$src/$item" "$TARGET/$item"
  done
fi

# 3. 校验必备文件与技能名
missing=""
for f in SKILL.md readme.md references/agents-template.md references/workflow-manual.md; do
  [ -f "$TARGET/$f" ] || missing="$missing $f"
done
[ -z "$missing" ] || { echo "✗ 安装失败，缺少：$missing" >&2; exit 1; }

name="$(awk '/^name:/{print $2; exit}' "$TARGET/SKILL.md")"
[ "$name" = "$SKILL_NAME" ] || { echo "✗ 安装失败：SKILL.md 的 name=${name}，应为 ${SKILL_NAME}" >&2; exit 1; }
echo "✓ 已安装：${TARGET}（name=${name}）"

# 4. 软链到已存在的工具技能目录
if [ "$LINK" -eq 1 ]; then
  linked=0
  for dir in \
    "$HOME/.dsh/skills" \
    "$HOME/.agents/skills" \
    "$HOME/.cursor/skills" \
    "$HOME/.codex/skills" \
    "$HOME/.claude/skills" \
    "$HOME/.workbuddy/skills" \
    "$HOME/.codebuddy/skills"; do
    [ -d "$dir" ] || continue
    [ "$(cd "$dir" && pwd)" = "$(dirname "$TARGET")" ] && continue
    link="$dir/$SKILL_NAME"
    if [ -L "$link" ] || [ -e "$link" ]; then
      echo "· 已存在，跳过：$link"
    else
      ln -s "$TARGET" "$link"
      echo "✓ 已链接：$link → $TARGET"
      linked=$((linked + 1))
    fi
  done
  [ "$linked" -eq 0 ] && echo "· 未发现需要新建链接的工具目录（可手动放到对应 skills 目录）"
fi

# 5. 调用提示
echo "下一步：在工具里用 /okgo 调用；Codex 用 \$okgo；Cursor 也可 @okgo。详见 $TARGET/readme.md"
