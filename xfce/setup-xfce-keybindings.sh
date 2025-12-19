#!/bin/bash

# XFCE4 Tiling WM Style Keybindings Setup Script
# Enables BOTH arrow keys AND numpad for tiling

set -e

echo "==========================================="
echo "XFCE4 Keyboard Shortcuts Configuration"
echo "Tiling with BOTH Arrows and Numpad"
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

# Clear Super_L/R whisker menu bindings (they can conflict)
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_R" -r 2>/dev/null || true

# Clear any bare arrow keys
xfconf-query -c xfwm4-keyboard-shortcuts -p "/xfwm4/custom/Left" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/Right" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/Up" -r 2>/dev/null || true
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/Down" -r 2>/dev/null || true

echo "  ✓ Conflicts cleared"

# ============================================
# STEP 3: TILING - ARROW KEYS
# ============================================
echo ""
echo "Step 3: Setting up tiling with Arrow Keys..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Left" -n -t string -s "tile_left_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Left" -s "tile_left_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Right" -n -t string -s "tile_right_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Right" -s "tile_right_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Up" -n -t string -s "tile_up_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Up" -s "tile_up_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Down" -n -t string -s "tile_down_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Down" -s "tile_down_key"

echo "  ✓ Arrow keys: Super+←/→/↑/↓"

# ============================================
# STEP 4: TILING - NUMPAD KEYS
# ============================================
echo ""
echo "Step 4: Setting up tiling with Numpad..."

# Cardinal directions (2,4,6,8)
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Left" -n -t string -s "tile_left_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Left" -s "tile_left_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Right" -n -t string -s "tile_right_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Right" -s "tile_right_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Up" -n -t string -s "tile_up_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Up" -s "tile_up_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Down" -n -t string -s "tile_down_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Down" -s "tile_down_key"

# Corners (1,3,7,9)
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Home" -n -t string -s "tile_up_left_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Home" -s "tile_up_left_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_7" -n -t string -s "tile_up_left_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_7" -s "tile_up_left_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Page_Up" -n -t string -s "tile_up_right_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Page_Up" -s "tile_up_right_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_9" -n -t string -s "tile_up_right_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_9" -s "tile_up_right_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_End" -n -t string -s "tile_down_left_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_End" -s "tile_down_left_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_1" -n -t string -s "tile_down_left_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_1" -s "tile_down_left_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Next" -n -t string -s "tile_down_right_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_Next" -s "tile_down_right_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_3" -n -t string -s "tile_down_right_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>KP_3" -s "tile_down_right_key"

echo "  ✓ Numpad: Super+KP_4/6/8/2 (directions)"
echo "  ✓ Numpad: Super+KP_7/9/1/3 (corners)"

# ============================================
# STEP 5: WORKSPACE SWITCHING (Alt + Number)
# ============================================
echo ""
echo "Step 5: Setting up workspace switching..."

for i in {1..9}; do
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>$i" -n -t string -s "workspace_${i}_key" 2>/dev/null || \
        xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt>$i" -s "workspace_${i}_key"
done

echo "  ✓ Alt+1 through Alt+9"

# ============================================
# STEP 6: MOVE WINDOW TO WORKSPACE
# ============================================
echo ""
echo "Step 6: Setting up move window to workspace..."

for i in {1..9}; do
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$i" -n -t string -s "move_window_workspace_${i}_key" 2>/dev/null || \
        xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Alt><Shift>$i" -s "move_window_workspace_${i}_key"
done

echo "  ✓ Alt+Shift+1 through Alt+Shift+9"

# ============================================
# STEP 7: WORKSPACE NAVIGATION
# ============================================
echo ""
echo "Step 7: Setting up workspace navigation..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketleft" -n -t string -s "left_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketleft" -s "left_workspace_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketright" -n -t string -s "right_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>bracketright" -s "right_workspace_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketleft" -n -t string -s "move_window_left_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketleft" -s "move_window_left_workspace_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketright" -n -t string -s "move_window_right_workspace_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super><Shift>bracketright" -s "move_window_right_workspace_key"

echo "  ✓ Super+[ and Super+] (navigate)"
echo "  ✓ Super+Shift+[ and Super+Shift+] (move window)"

# ============================================
# STEP 8: WINDOW MANAGEMENT
# ============================================
echo ""
echo "Step 8: Setting up window management..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Page_Up" -n -t string -s "maximize_window_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Page_Up" -s "maximize_window_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>f" -n -t string -s "fullscreen_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>f" -s "fullscreen_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>q" -n -t string -s "close_window_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>q" -s "close_window_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>d" -n -t string -s "show_desktop_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>d" -s "show_desktop_key"

xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Tab" -n -t string -s "switch_window_key" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Super>Tab" -s "switch_window_key"

echo "  ✓ Super+Page_Up (maximize)"
echo "  ✓ Super+F (fullscreen)"
echo "  ✓ Super+Q (close)"
echo "  ✓ Super+D (show desktop)"
echo "  ✓ Super+Tab (window switcher)"

# ============================================
# STEP 9: APPLICATION LAUNCHERS
# ============================================
echo ""
echo "Step 9: Setting up application launchers..."

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>Return" -n -t string -s "ghostty" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>Return" -s "ghostty"

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>b" -n -t string -s "flatpak run io.github.zen_browser.zen" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>b" -s "flatpak run io.github.zen_browser.zen"

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>e" -n -t string -s "thunar" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>e" -s "thunar"

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -n -t string -s "xflock4" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -s "xflock4"

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>space" -n -t string -s "xfce4-appfinder" 2>/dev/null || \
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Alt>space" -s "xfce4-appfinder"

echo "  ✓ Super+Enter (Ghostty)"
echo "  ✓ Super+B (Zen Browser)"
echo "  ✓ Super+E (Thunar)"
echo "  ✓ Super+L (Lock)"
echo "  ✓ Alt+Space (App Finder)"

# ============================================
# STEP 10: RESTART WINDOW MANAGER
# ============================================
echo ""
echo "Step 10: Restarting window manager..."

killall xfwm4 2>/dev/null || true
sleep 1
xfwm4 &
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
echo "  Super+Left  : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Left' 2>/dev/null || echo 'NOT SET')"
echo "  Super+Right : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Right' 2>/dev/null || echo 'NOT SET')"
echo "  Super+Up    : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Up' 2>/dev/null || echo 'NOT SET')"
echo "  Super+Down  : $(xfconf-query -c xfce4-keyboard-shortcuts -p '/xfwm4/custom/<Super>Down' 2>/dev/null || echo 'NOT SET')"

echo ""
echo "Numpad Tiling:"
echo "  Super+KP_4/6/8/2 (←/→/↑/↓) - directions"
echo "  Super+KP_7/9/1/3 (corners)"

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
echo "Tiling (Arrows OR Numpad):"
echo "  Super+←/→/↑/↓          → Tile window"
echo "  Super+KP_4/6/8/2       → Tile window (numpad)"
echo "  Super+KP_7/9/1/3       → Corner tiling"
echo ""
echo "Workspaces:"
echo "  Alt+1-9                → Switch to workspace"
echo "  Alt+Shift+1-9          → Move window to workspace"
echo "  Super+[/]              → Previous/next workspace"
echo "  Super+Shift+[/]        → Move window to prev/next"
echo ""
echo "Window Management:"
echo "  Super+Page_Up          → Maximize"
echo "  Super+F                → Fullscreen"
echo "  Super+Q                → Close window"
echo ""
echo "If tiling doesn't work, check:"
echo "  Settings → Window Manager Tweaks → Accessibility"
echo "  Make sure 'Key used to grab windows' is NOT Super"
