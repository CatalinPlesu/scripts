#!/bin/bash

# XFCE4 Tiling WM Style Keybindings Setup Script
# Modifier key: Alt

xfconf-query -c xfwm4 -p /general/activate_action -s none

set -e

echo "==========================================="
echo "XFCE4 Keyboard Shortcuts Configuration"
echo "Modifier: Alt"
echo "==========================================="
echo ""

# ============================================
# STEP 1: ENABLE XFWM4 TILING FEATURES
# ============================================
echo "Step 1: Enabling XFWM4 tiling features..."

xfconf-query -c xfwm4 -p /general/tile_on_move -n -t bool -s true 2>/dev/null || \
    xfconf-query -c xfwm4 -p /general/tile_on_move -s true
xfconf-query -c xfwm4 -p /general/snap_to_border -n -t bool -s true 2>/dev/null || \
    xfconf-query -c xfwm4 -p /general/snap_to_border -s true
xfconf-query -c xfwm4 -p /general/snap_to_windows -n -t bool -s true 2>/dev/null || \
    xfconf-query -c xfwm4 -p /general/snap_to_windows -s true

echo "  ✓ Tiling enabled"

# ============================================
# STEP 2: CLEAR CONFLICTING BINDINGS
# ============================================
echo ""
echo "Step 2: Clearing conflicting keybindings..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_R" -r 2>/dev/null || true

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/Left" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/Right" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/Up" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/Down" -r 2>/dev/null || true

# Clear old Super bindings
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Left" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Right" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Up" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Down" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Page_Up" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>f" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>q" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>d" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Tab" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketleft" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketright" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketleft" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketright" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>Return" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>b" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>e" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -r 2>/dev/null || true

echo "  ✓ Conflicts cleared"

# ============================================
# STEP 3: TILING - ARROW KEYS
# ============================================
echo ""
echo "Step 3: Setting up tiling with Arrow Keys..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Left" -n -t string -s "tile_left_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Left" -s "tile_left_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Right" -n -t string -s "tile_right_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Right" -s "tile_right_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Up" -n -t string -s "tile_up_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Up" -s "tile_up_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Down" -n -t string -s "tile_down_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Down" -s "tile_down_key"

echo "  ✓ Arrow keys: Alt+←/→/↑/↓"

# ============================================
# STEP 4: WORKSPACE SWITCHING (Alt + Number)
# ============================================
echo ""
echo "Step 4: Setting up workspace switching..."

for i in {1..9}; do
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>$i" -n -t string -s "workspace_${i}_key" 2>/dev/null || \
        xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>$i" -s "workspace_${i}_key"
done

echo "  ✓ Alt+1 through Alt+9"

# ============================================
# STEP 5: MOVE WINDOW TO WORKSPACE
# ============================================
echo ""
echo "Step 5: Setting up move window to workspace..."

for i in {1..9}; do
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$i" -n -t string -s "move_window_workspace_${i}_key" 2>/dev/null || \
        xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$i" -s "move_window_workspace_${i}_key"
done

echo "  ✓ Alt+Shift+1 through Alt+Shift+9"

# ============================================
# STEP 6: WORKSPACE NAVIGATION
# ============================================
echo ""
echo "Step 6: Setting up workspace navigation..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>bracketleft" -n -t string -s "left_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>bracketleft" -s "left_workspace_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>bracketright" -n -t string -s "right_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>bracketright" -s "right_workspace_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>bracketleft" -n -t string -s "move_window_left_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>bracketleft" -s "move_window_left_workspace_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>bracketright" -n -t string -s "move_window_right_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>bracketright" -s "move_window_right_workspace_key"

echo "  ✓ Alt+[ and Alt+] (navigate)"
echo "  ✓ Alt+Shift+[ and Alt+Shift+] (move window)"

# ============================================
# STEP 7: WINDOW MANAGEMENT
# ============================================
echo ""
echo "Step 7: Setting up window management..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Page_Up" -n -t string -s "maximize_window_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Page_Up" -s "maximize_window_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>f" -n -t string -s "fullscreen_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>f" -s "fullscreen_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>q" -n -t string -s "close_window_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>q" -s "close_window_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>d" -n -t string -s "show_desktop_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>d" -s "show_desktop_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Tab" -n -t string -s "cycle_windows_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>Tab" -s "cycle_windows_key"

echo "  ✓ Alt+Page_Up (maximize)"
echo "  ✓ Alt+F (fullscreen)"
echo "  ✓ Alt+Q (close)"
echo "  ✓ Alt+D (show desktop)"
echo "  ✓ Alt+Tab (window switcher)"

# ============================================
# STEP 8: APPLICATION LAUNCHERS
# ============================================
echo ""
echo "Step 8: Setting up application launchers..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>Return" -n -t string -s "ghostty" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>Return" -s "ghostty"

zfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>b" -n -t string -s "zen-browser" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>b" -s "zen-browser"

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>e" -n -t string -s "thunar" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>e" -s "thunar"

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>l" -n -t string -s "xflock4" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>l" -s "xflock4"

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>space" -n -t string -s "xfce4-appfinder" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>space" -s "xfce4-appfinder"

echo "  ✓ Alt+Enter (Ghostty)"
echo "  ✓ Alt+B (Zen Browser)"
echo "  ✓ Alt+E (Thunar)"
echo "  ✓ Alt+L (Lock)"
echo "  ✓ Alt+Space (App Finder)"

# ============================================
# STEP 9: RESTART WINDOW MANAGER
# ============================================
echo ""
echo "Step 9: Restarting window manager..."

xfwm4 --replace &
disown
sleep 2

echo "  ✓ XFWM4 restarted"

# ============================================
# VERIFICATION
# ============================================
echo ""
echo "==========================================="
echo "VERIFICATION"
echo "==========================================="
echo ""

echo "Arrow Keys Tiling:"
echo "  Alt+Left  : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>Left' 2>/dev/null || echo 'NOT SET')"
echo "  Alt+Right : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>Right' 2>/dev/null || echo 'NOT SET')"
echo "  Alt+Up    : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>Up' 2>/dev/null || echo 'NOT SET')"
echo "  Alt+Down  : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Alt>Down' 2>/dev/null || echo 'NOT SET')"

echo ""
echo "XFWM4 Tiling Enabled:"
echo "  tile_on_move: $(xfconf-query -c xfwm4 -p /general/tile_on_move)"

echo ""
echo "==========================================="
echo "✓ Configuration complete!"
echo "==========================================="
echo ""
echo "QUICK REFERENCE:"
echo ""
echo "Tiling:"
echo "  Alt+←/→/↑/↓           → Tile window"
echo ""
echo "Workspaces:"
echo "  Alt+1-9                → Switch to workspace"
echo "  Alt+Shift+1-9          → Move window to workspace"
echo "  Alt+[/]                → Previous/next workspace"
echo "  Alt+Shift+[/]          → Move window to prev/next"
echo ""
echo "Window Management:"
echo "  Alt+Page_Up            → Maximize"
echo "  Alt+F                  → Fullscreen"
echo "  Alt+Q                  → Close window"
echo "  Alt+D                  → Show desktop"
echo "  Alt+Tab                → Cycle windows"
echo ""
echo "Launchers:"
echo "  Alt+Enter              → Ghostty"
echo "  Alt+B                  → Zen Browser"
echo "  Alt+E                  → Thunar"
echo "  Alt+L                  → Lock screen"
echo "  Alt+Space              → App Finder"
echo ""
echo "NOTE: Alt+Tab and Alt+F4 are used by many apps."
echo "If conflicts arise, consider moving those to Alt+Shift."
