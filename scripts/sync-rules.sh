#!/bin/bash
# sync-rules.sh

# --- Configuration ---
RULES_FILE="docs/rules/rules.md"
CLAUDE_FILE="CLAUDE.md"
COPILOT_FILE=".github/copilot-instructions.md"
CONTINUE_FILE=".continue/rules/main.md"
CURSOR_FILE=".cursor/rules/main.mdc"

# Files to ignore in git (local only)
IGNORE_LIST=(
    ".continue/"
    ".cursor/"
    ".github/copilot-instructions.md"
)

# --- Helper Functions ---

log_info() {
    printf '[INFO] %s\n' "$1"
}

log_success() {
    printf '[SUCCESS] %s\n' "$1"
}

log_error() {
    printf '[ERROR] %s\n' "$1"
}

check_rules_exists() {
    if [ ! -f "$RULES_FILE" ]; then
        log_error "Rules file not found: $RULES_FILE"
        exit 1
    fi
}

update_git_exclude() {
    local action=$1
    local pattern=$2
    local git_exclude=".git/info/exclude"
    local git_exclude_dir=".git/info"

    if [ ! -d "$git_exclude_dir" ]; then
        log_error "Git metadata directory not found: $git_exclude_dir"
        exit 1
    fi

    if [ ! -f "$git_exclude" ]; then
        touch "$git_exclude"
    fi

    if [ "$action" == "add" ]; then
        if ! grep -Fxq "$pattern" "$git_exclude"; then
            echo "$pattern" >> "$git_exclude"
            log_info "Added $pattern to $git_exclude"
        else
            log_info "$pattern already in $git_exclude"
        fi
    elif [ "$action" == "remove" ]; then
        if grep -Fxq "$pattern" "$git_exclude"; then
            # Avoid regex/sed escaping issues for patterns like ".continue/".
            local tmp_file
            tmp_file=$(mktemp)
            grep -Fvx -- "$pattern" "$git_exclude" > "$tmp_file" || true
            cat "$tmp_file" > "$git_exclude"
            rm -f "$tmp_file"
            log_info "Removed $pattern from $git_exclude"
        else
            log_info "$pattern not in $git_exclude"
        fi
    fi
}

# --- Core Logic ---

install() {
    check_rules_exists
    log_info "Starting rules installation..."

    # 1. Claude Code
    cp "$RULES_FILE" "$CLAUDE_FILE"
    log_info "Copied rules to $CLAUDE_FILE"

    # 2. Copilot
    mkdir -p .github
    cp "$RULES_FILE" "$COPILOT_FILE"
    log_info "Copied rules to $COPILOT_FILE"

    # 3. Continue (with YAML frontmatter)
    mkdir -p .continue/rules
    cat > "$CONTINUE_FILE" << EOF
---
name: Project Rules
alwaysApply: true
---

$(cat "$RULES_FILE")
EOF
    log_info "Created $CONTINUE_FILE with frontmatter"

    # 4. Cursor (with YAML frontmatter)
    mkdir -p .cursor/rules
    cat > "$CURSOR_FILE" << EOF
---
description: Project Rules
alwaysApply: true
---

$(cat "$RULES_FILE")
EOF
    log_info "Created $CURSOR_FILE with frontmatter"

    # 5. Update .git/info/exclude
    for pattern in "${IGNORE_LIST[@]}"; do
        update_git_exclude "add" "$pattern"
    done

    log_success "Rules installation complete!"
}

uninstall() {
    log_info "Starting rules uninstallation..."

    # 1. Remove files
    rm -f "$CLAUDE_FILE" "$COPILOT_FILE" "$CONTINUE_FILE" "$CURSOR_FILE"
    log_info "Removed AI config files"

    # 2. Remove directories if empty
    rmdir .continue/rules 2>/dev/null || true
    rmdir .continue 2>/dev/null || true
    rmdir .cursor/rules 2>/dev/null || true
    rmdir .cursor 2>/dev/null || true

    # 3. Update .git/info/exclude
    for pattern in "${IGNORE_LIST[@]}"; do
        update_git_exclude "remove" "$pattern"
    done

    log_success "Rules uninstallation complete!"
}

# --- Main Entry Point ---

case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        exit 1
        ;;
esac
