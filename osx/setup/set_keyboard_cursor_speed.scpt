#!/usr/bin/osascript

# Set the keyboard cursor speed to the maximum OSX allows in 'System Preferences'.

try
    tell application "System Preferences"
        activate
        set current pane to pane "com.apple.preference.keyboard"
    end tell
    
    tell application "System Events"
        tell process "System Preferences"
            delay 0.5
            click radio button "Keyboard" of tab group 1 of window "Keyboard"
            delay 0.5

            set value of slider "Key Repeat" of tab group 1 of window "keyboard" to 100
            set value of slider "Delay Until Repeat" of tab group 1 of window "keyboard" to 100

        end tell
    end tell

    delay 0.5

    tell application "System Preferences" to close window 1
end try

