#!/bin/bash

# XFCE4 Tiling WM Style Keybindings Setup Script
# This script CLEARS old bindings first, then sets new ones

set -e

echo "==========================================="
echo "XFCE4 Keyboard Shortcuts Configuration"
echo "==========================================="
echo ""

# ============================================
# STEP 1: CLEAR ALL CONFLICTING BINDINGS
# ============================================
echo "Step 1: Clearing all conflicting keybindings..."

# Clear ALL Super key bindings that we'll be setting
BINDINGS_TO_CLEAR=(
    # Workspace switching
    "<Alt>1" "<Alt>2" "<Alt>3" "<Alt>4" "<Alt>5" "<Alt>6" "<Alt>7" "<Alt>8" "<Alt>9"
    
    # Workspace navigation
    "<Super>bracketleft"
    "<Super>bracketright"
    
    # Move window to workspace
    "<Super><Shift>bracketleft"
    "<Super><Shift>bracketright"
    "<Alt><Shift>1" "<Alt><Shift>2" "<Alt><Shift>3" "<Alt><Shift>4" "<Alt><Shift>5"
    "<Alt><Shift>6" "<Alt><Shift>7" "<Alt><Shift>8" "<Alt><Shift>9"
    
    # Tiling - Arrow keys (IMPORTANT!)
    "<Super>Left"
    "<Super>Right"
    "<Super>Up"
    "<Super>Down"
    
    # Tiling - Numpad
    "<Super>KP_Left"
    "<Super>KP_Right"
    "<Super>KP_Up"
    "<Super>KP_Down"
    "<Super>KP_Home"
    "<Super>KP_Page_Up"
    "<Super>KP_End"
    "<Super>KP_Next"
    "<Super>KP_1"
    "<Super>KP_3"
    "<Super>KP_7"
    "<Super>KP_9"
    
    # Window management
    "<Super>Page_Up"
    "<Super>f"
    "<Super>q"
    "<Super>d"
    "<Super>Tab"
    "<Alt>Tab"
    "<Alt><Shift>Tab"
    "<Alt>F4"
    
    # Bare arrow keys (these might conflict!)
    "Left"
    "Right"
    "Up"
    "Down"
    
    # Old F-key bindings we don't want
    "<Alt>F5" "<Alt>F6" "<Alt>F7" "<Alt>F8" "<Alt>F9" "<Alt>F11" "<Alt>F12"
    "<Primary><Alt>Home" "<Primary><Alt>End"
    "<Primary><Alt><Shift>bracketleft" "<Primary><Alt><Shift>bracketright"
)

for binding in "${BINDINGS_TO_CLEAR[@]}"; do
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/$binding" -r 2>/dev/null || true
done

echo "✓ Cleared old bindings"
echo ""

# Also clear problematic command bindings
COMMAND_BINDINGS_TO_CLEAR=(
    "<Super>r"
    "<Super>w"
    "<Super>t"
    "<Super>m"
)

for binding in "${COMMAND_BINDINGS_TO_CLEAR[@]}"; do
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$binding" -r 2>/dev/null || true
done

# ============================================
# STEP 2: DISABLE PROBLEMATIC FEATURES
# ============================================
echo "Step 2: Disabling drag-to-edge workspace switching..."

xfconf-query -c xfwm4 -p /general/wrap_workspaces -n -t bool -s false
xfconf-query -c xfwm4 -p /general/wrap_windows -n -t bool -s false
xfconf-query -c xfwm4 -p /general/scroll_workspaces -n -t bool -s false
xfconf-query -c xfwm4 -p /general/wrap_cycle -n -t bool -s false

echo "✓ Disabled edge behaviors"
echo ""

# ============================================
# STEP 3: SET NEW BINDINGS
# ============================================
echo "Step 3: Setting up new keybindings..."

# ---- Workspace switching (Alt + Number) ----
echo "  → Workspace switching (Alt+1-9)..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>1" -n -t string -s "workspace_1_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>2" -n -t string -s "workspace_2_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>3" -n -t string -s "workspace_3_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>4" -n -t string -s "workspace_4_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>5" -n -t string -s "workspace_5_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>6" -n -t string -s "workspace_6_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>7" -n -t string -s "workspace_7_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>8" -n -t string -s "workspace_8_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>9" -n -t string -s "workspace_9_key"

# ---- Workspace navigation (Super + [ ]) ----
echo "  → Workspace navigation (Super+[ and Super+])..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketleft" -n -t string -s "left_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketright" -n -t string -s "right_workspace_key"

# ---- Move window to workspace (Super + Shift + [ ]) ----
echo "  → Move window to workspace (Super+{ and Super+})..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketleft" -n -t string -s "move_window_left_workspace_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketright" -n -t string -s "move_window_right_workspace_key"

# ---- Window tiling (Super + Arrows) ----
echo "  → Window tiling (Super+Arrows)..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Left" -n -t string -s "tile_left_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Right" -n -t string -s "tile_right_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Up" -n -t string -s "tile_up_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Down" -n -t string -s "tile_down_key"

# ---- Window tiling - Numpad (backup) ----
echo "  → Window tiling numpad (Super+Numpad)..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Left" -n -t string -s "tile_left_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Right" -n -t string -s "tile_right_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Up" -n -t string -s "tile_up_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Down" -n -t string -s "tile_down_key"

# ---- Corner tiling (numpad) ----
echo "  → Corner tiling (Super+Numpad corners)..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Home" -n -t string -s "tile_up_left_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Page_Up" -n -t string -s "tile_up_right_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_End" -n -t string -s "tile_down_left_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Next" -n -t string -s "tile_down_right_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_1" -n -t string -s "tile_down_left_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_3" -n -t string -s "tile_down_right_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_7" -n -t string -s "tile_up_left_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_9" -n -t string -s "tile_up_right_key"

# ---- Window management ----
echo "  → Window management (maximize, fullscreen, close)..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Page_Up" -n -t string -s "maximize_window_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>f" -n -t string -s "fullscreen_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>q" -n -t string -s "close_window_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>F4" -n -t string -s "close_window_key"

# ---- Window cycling ----
echo "  → Window cycling (Alt+Tab)..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Tab" -n -t string -s "cycle_windows_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>Tab" -n -t string -s "cycle_reverse_windows_key"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Tab" -n -t string -s "switch_window_key"

# ---- Show desktop ----
echo "  → Show desktop (Super+D)..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>d" -n -t string -s "show_desktop_key"

# ---- Applications ----
echo "  → Application launchers..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>Return" -n -t string -s "ghostty"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>b" -n -t string -s "flatpak run io.github.zen_browser.zen"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>e" -n -t string -s "thunar"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -n -t string -s "xflock4"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>space" -n -t string -s "xfce4-appfinder"

# ---- Screenshots ----
echo "  → Screenshot shortcuts..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Print" -n -t string -s "xfce4-screenshooter -f"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Shift>Print" -n -t string -s "xfce4-screenshooter -r"

echo ""
echo "✓ All keybindings configured successfully!"
echo ""

# ============================================
# VERIFICATION
# ============================================
echo "==========================================="
echo "VERIFICATION"
echo "==========================================="
echo ""
echo "Checking Super+Right binding:"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Right"
echo ""
echo "Checking Super+Left binding:"
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Left"
echo ""

echo "==========================================="
echo "SUMMARY OF KEYBINDINGS"
echo "==========================================="
echo ""
echo "Workspaces:"
echo "  Alt+1-9                → Switch to workspace 1-9"
echo "  Super+[                → Previous workspace"
echo "  Super+]                → Next workspace"
echo "  Super+{ (Shift+[)      → Move window to previous workspace"
echo "  Super+} (Shift+])      → Move window to next workspace"
echo ""
echo "Window Tiling:"
echo "  Super+Left             → Tile window left (50%)"
echo "  Super+Right            → Tile window right (50%)"
echo "  Super+Up               → Tile window up (50%)"
echo "  Super+Down             → Tile window down (50%)"
echo "  Super+Numpad arrows    → Same as above (backup)"
echo "  Super+Numpad corners   → Tile to corners (25%)"
echo ""
echo "Window Management:"
echo "  Super+Page_Up          → Maximize window"
echo "  Super+F                → Toggle fullscreen"
echo "  Super+Q                → Close window"
echo "  Alt+F4                 → Close window (traditional)"
echo "  Super+D                → Show desktop"
echo ""
echo "Window Cycling:"
echo "  Alt+Tab                → Cycle windows forward"
echo "  Alt+Shift+Tab          → Cycle windows backward"
echo "  Super+Tab              → Window switcher"
echo ""
echo "Applications:"
echo "  Super+Enter            → Ghostty terminal"
echo "  Super+B                → Zen Browser"
echo "  Super+E                → File manager (Thunar)"
echo "  Super+L                → Lock screen"
echo "  Super+Space            → App Finder"
echo ""
echo "Screenshots:"
echo "  Print                  → Full screen screenshot"
echo "  Shift+Print            → Region screenshot"
echo ""
echo "==========================================="
echo "✓ Configuration complete!"
echo "==========================================="
echo ""
echo "NOTE: If tiling still doesn't work, try:"
echo "  1. Log out and log back in"
echo "  2. Run: xfwm4 --replace &"
echo "  3. Check Settings → Window Manager Tweaks → Compositor"
echo ""
