#!/usr/bin/env bash

# ============================================================================
# ui.sh — CLI Academy UI Library
# All user-facing output goes through these functions.
# Supports graceful degradation when terminal lacks color support.
# ============================================================================

# --- Color Detection ---
# Use tput when available, fall back to hardcoded ANSI, disable if no support.

UI_HAS_COLOR=false

if [[ -t 1 ]] && command -v tput &>/dev/null && [[ -n "${TERM:-}" ]]; then
  _colors=$(tput colors 2>/dev/null || echo 0)
  if [[ "$_colors" -ge 8 ]]; then
    UI_HAS_COLOR=true
  fi
fi

if $UI_HAS_COLOR; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  MAGENTA=$(tput setaf 5)
  CYAN=$(tput setaf 6)
  BOLD=$(tput bold)
  DIM=$(tput dim 2>/dev/null || echo "")
  NC=$(tput sgr0)
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  MAGENTA=""
  CYAN=""
  BOLD=""
  DIM=""
  NC=""
fi

# --- Message Functions ---

msg_success() {
  if $UI_HAS_COLOR; then
    echo -e "${GREEN}${BOLD}🎉 $1${NC}"
  else
    echo "[PASS] $1"
  fi
}

msg_fail() {
  if $UI_HAS_COLOR; then
    echo -e "${RED}${BOLD}❌ $1${NC}"
  else
    echo "[FAIL] $1"
  fi
}

msg_info() {
  if $UI_HAS_COLOR; then
    echo -e "${BLUE}ℹ️  $1${NC}"
  else
    echo "[INFO] $1"
  fi
}

msg_warn() {
  if $UI_HAS_COLOR; then
    echo -e "${YELLOW}⚠️  $1${NC}"
  else
    echo "[WARN] $1"
  fi
}

# --- Banner ---
# Decorative banner for game start / completion

banner() {
  local TEXT="$1"
  local WIDTH=45
  local PAD=$(( (WIDTH - ${#TEXT}) / 2 ))
  if [[ $PAD -lt 0 ]]; then PAD=0; fi
  local PADDING=""
  for (( i=0; i<PAD; i++ )); do PADDING+=" "; done

  echo ""
  if $UI_HAS_COLOR; then
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}${YELLOW}${BOLD}${PADDING}${TEXT}${PADDING}${NC}${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════╝${NC}"
  else
    echo "==========================================="
    echo "${PADDING}${TEXT}"
    echo "==========================================="
  fi
  echo ""
}

# --- Level Header ---
# Shows level number, name, and tier

ui_level_header() {
  local LEVEL="$1"
  local NAME="${2:-}"
  local TIER="${3:-}"

  if $UI_HAS_COLOR; then
    echo ""
    echo -e "${MAGENTA}${BOLD}━━━ Level ${LEVEL} ━━━${NC}"
    if [[ -n "$NAME" ]]; then
      echo -e "${YELLOW}${BOLD}  ${NAME}${NC}"
    fi
    if [[ -n "$TIER" ]]; then
      local TIER_COLOR="$DIM"
      case "$TIER" in
        beginner)     TIER_COLOR="$GREEN" ;;
        intermediate) TIER_COLOR="$YELLOW" ;;
        advanced)     TIER_COLOR="$RED" ;;
        master)       TIER_COLOR="$MAGENTA" ;;
        boss)         TIER_COLOR="${RED}${BOLD}" ;;
      esac
      echo -e "  ${TIER_COLOR}[${TIER^^}]${NC}"
    fi
    echo ""
  else
    echo ""
    echo "--- Level ${LEVEL} ---"
    [[ -n "$NAME" ]] && echo "  ${NAME}"
    [[ -n "$TIER" ]] && echo "  [${TIER}]"
    echo ""
  fi
}

# --- Hint Tip ---

show_hint_tip() {
  local LEVEL=$1
  local HINT_FILE="levels/level${LEVEL}/hint.txt"
  if [[ -f "$HINT_FILE" ]]; then
    if $UI_HAS_COLOR; then
      echo -e "${YELLOW}💡 Need help? Run: ./play.sh hint $LEVEL${NC}"
    else
      echo "[TIP] Need help? Run: ./play.sh hint $LEVEL"
    fi
  fi
}

# --- Continue Prompt ---

ui_continue_prompt() {
  if $UI_HAS_COLOR; then
    read -p "$(echo -e "${CYAN}👉 Continue to next level? (y/N): ${NC}")" CONTINUE
  else
    read -p "Continue to next level? (y/N): " CONTINUE
  fi
  echo "$CONTINUE"
}

# --- Progress Bar ---
# Usage: ui_progress 15 46

ui_progress() {
  local DONE=$1
  local TOTAL=$2
  local PCT=0
  if [[ $TOTAL -gt 0 ]]; then
    PCT=$(( DONE * 100 / TOTAL ))
  fi

  if $UI_HAS_COLOR; then
    local BAR_WIDTH=30
    local FILLED=$(( DONE * BAR_WIDTH / TOTAL ))
    local EMPTY=$(( BAR_WIDTH - FILLED ))
    local BAR=""
    for (( i=0; i<FILLED; i++ )); do BAR+="█"; done
    for (( i=0; i<EMPTY; i++ )); do BAR+="░"; done
    echo -e "${DIM}Progress: ${NC}${GREEN}${BAR}${NC} ${BOLD}${DONE}/${TOTAL}${NC} ${DIM}(${PCT}%)${NC}"
  else
    echo "Progress: ${DONE}/${TOTAL} (${PCT}%)"
  fi
}
