#!/usr/bin/env bash

# ==============================================================================
# CONFIGURABLE MODIFIER VARIABLE
# Set this to "<Alt>" or "<Super>".
# ==============================================================================
MOD="<Alt>"
MOD_NAME="Alt"

echo "🔧 Bypassing GNOME extension version checks..."
gsettings set org.gnome.shell disable-extension-version-validation true

echo "📂 Configuring exactly 10 permanent workspaces..."
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10

echo "🗑️ Wiping conflicting default GNOME keybindings..."
for key in $(gsettings list-keys org.gnome.desktop.wm.keybindings); do
    if [[ ! "$key" =~ ^switch-to-workspace-[0-9]+$ ]] && [[ ! "$key" =~ ^move-to-workspace-[0-9]+$ ]]; then
        gsettings set org.gnome.desktop.wm.keybindings "$key" "@as []" 2>/dev/null || \
        gsettings set org.gnome.desktop.wm.keybindings "$key" "0" 2>/dev/null
    fi
done

for key in $(gsettings list-keys org.gnome.settings-daemon.plugins.media-keys); do
    if [ "$key" != "screenshot" ] && [ "$key" != "window-screenshot" ] && [ "$key" != "area-screenshot" ] && [ "$key" != "custom-keybindings" ]; then
        gsettings set org.gnome.settings-daemon.plugins.media-keys "$key" "@as []" 2>/dev/null || \
        gsettings set org.gnome.settings-daemon.plugins.media-keys "$key" "0" 2>/dev/null
    fi
done

for key in $(gsettings list-keys org.gnome.shell.keybindings); do
    gsettings set org.gnome.shell.keybindings "$key" "@as []" 2>/dev/null || \
    gsettings set org.gnome.shell.keybindings "$key" "0" 2>/dev/null
done

echo "🔕 Disabling Super overview key so it never eats combos..."
gsettings set org.gnome.mutter overlay-key ''

echo "⌨️ Assigning standard Workspace mappings using ${MOD_NAME}..."
for i in {1..9}; do
    gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$i" "['${MOD}${i}']"
    gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$i" "['${MOD}<Shift>${i}']"
done
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-10 "['${MOD}0']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-10 "['${MOD}<Shift>0']"

echo "🛠️ Creating app specific system-level shortcuts..."
gsettings set org.gnome.shell.keybindings toggle-application-view "['${MOD}space']"
gsettings set org.gnome.desktop.wm.keybindings close "['${MOD}q']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['${MOD}<Shift>space']"

echo "🚀 Mapping custom application launchers..."
KB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
KB_SCHEMA="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "['${KB_PATH}/custom0/', '${KB_PATH}/custom1/']"

# ------------------------------------------------------------------------------
# Resolve browser command (handles Flatpak too)
# ------------------------------------------------------------------------------
if command -v zen-browser &>/dev/null; then
    BROWSER_CMD="$(command -v zen-browser)"
elif flatpak list --app 2>/dev/null | grep -qi zen; then
    BROWSER_CMD="flatpak run app.zen_browser.zen"
else
    BROWSER_CMD="/usr/bin/zen-browser"
    echo "⚠️  Warning: zen-browser not found in PATH or Flatpak, using fallback path."
fi

if command -v ghostty &>/dev/null; then
    TERMINAL_CMD="$(command -v ghostty)"
else
    TERMINAL_CMD="/usr/bin/ghostty"
    echo "⚠️  Warning: ghostty not found in PATH, using fallback path."
fi

echo "   -> Browser command resolved to: ${BROWSER_CMD}"
echo "   -> Terminal command resolved to: ${TERMINAL_CMD}"

# Custom Bind 1: MOD + B for Zen Browser
gsettings set ${KB_SCHEMA}:${KB_PATH}/custom0/ name "Launch Zen Browser"
gsettings set ${KB_SCHEMA}:${KB_PATH}/custom0/ command "${BROWSER_CMD}"
gsettings set ${KB_SCHEMA}:${KB_PATH}/custom0/ binding "${MOD}b"

# Custom Bind 2: MOD + Enter for Ghostty Terminal
gsettings set ${KB_SCHEMA}:${KB_PATH}/custom1/ name "Launch Ghostty Terminal"
gsettings set ${KB_SCHEMA}:${KB_PATH}/custom1/ command "${TERMINAL_CMD}"
gsettings set ${KB_SCHEMA}:${KB_PATH}/custom1/ binding "${MOD}Return"

# ------------------------------------------------------------------------------
# Verify custom bindings actually took (no more silent failures)
# ------------------------------------------------------------------------------
echo "🔍 Verifying custom launcher bindings..."
echo "   custom0 name:    $(gsettings get ${KB_SCHEMA}:${KB_PATH}/custom0/ name)"
echo "   custom0 command: $(gsettings get ${KB_SCHEMA}:${KB_PATH}/custom0/ command)"
echo "   custom0 binding: $(gsettings get ${KB_SCHEMA}:${KB_PATH}/custom0/ binding)"
echo "   custom1 name:    $(gsettings get ${KB_SCHEMA}:${KB_PATH}/custom1/ name)"
echo "   custom1 command: $(gsettings get ${KB_SCHEMA}:${KB_PATH}/custom1/ command)"
echo "   custom1 binding: $(gsettings get ${KB_SCHEMA}:${KB_PATH}/custom1/ binding)"
echo "   custom-keybindings list: $(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)"

echo "🧩 Reconfiguring Forge internal bindings..."
FORGE_SCHEMA="org.gnome.shell.extensions.forge.keybindings"
FORGE_DIR="$HOME/.local/share/gnome-shell/extensions/forge@jmmaranan.com"
FORGE_SCHEMADIR="${FORGE_DIR}/schemas"

if [ ! -d "$FORGE_SCHEMADIR" ]; then
    echo "❌ ERROR: Forge schema dir not found at $FORGE_SCHEMADIR"
    echo "   Check your Forge extension install path and update FORGE_DIR."
else
    gset_forge() {
        gsettings --schemadir "$FORGE_SCHEMADIR" set $FORGE_SCHEMA "$@"
    }

    gset_forge focus-left  "['${MOD}h']"
    gset_forge focus-down  "['${MOD}j']"
    gset_forge focus-up    "['${MOD}k']"
    gset_forge focus-right "['${MOD}l']"

    gset_forge swap-left  "['${MOD}<Shift>h']"
    gset_forge swap-down  "['${MOD}<Shift>j']"
    gset_forge swap-up    "['${MOD}<Shift>k']"
    gset_forge swap-right "['${MOD}<Shift>l']"

    gset_forge toggle-tiling "['${MOD}w']"
    gset_forge toggle-float  "['${MOD}c']"
fi

echo "✅ Done! Log out and back in to fully refresh GNOME."
