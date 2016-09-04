#!/usr/bin/osascript

# Toggle the mouse/trackpad scroll direction.

tell application "System Preferences"
    activate
    set current pane to pane "com.apple.preference.trackpad"
end tell

tell application "System Events"
    tell process "System Preferences"
        delay 0.5
        click radio button "Scroll & Zoom" of tab group 1 of window "Trackpad"
        delay 0.5
        click checkbox 1 of tab group 1 of window "Trackpad"
    end tell
end tell

delay 0.5

tell application "System Preferences" to close window 1

