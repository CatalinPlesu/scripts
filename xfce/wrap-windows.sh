# ============================================
# DISABLE DRAG TO EDGE WORKSPACE SWITCHING
# ============================================
echo "Disabling drag to screen edge workspace switching..."

# Disable wrap workspaces (prevents wraparound)
xfconf-query -c xfwm4 -p /general/wrap_workspaces -n -t bool -s false

# Disable wrap windows (THIS is the one that prevents drag-to-edge workspace switching)
xfconf-query -c xfwm4 -p /general/wrap_windows -n -t bool -s false

# Disable workspace scroll (prevents accidental mouse wheel switching)
xfconf-query -c xfwm4 -p /general/scroll_workspaces -n -t bool -s false

# Optionally, make sure wrap_cycle is also disabled
xfconf-query -c xfwm4 -p /general/wrap_cycle -n -t bool -s false
