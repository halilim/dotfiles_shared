#!/usr/bin/env osascript

on run argv
  if count of argv > 0 then
    set op to first item of argv -- Anything else will be "receive"
  else
    set op to "send"
  end if

  -- `return`s are for debugging, `log` or `dlog` from https://stackoverflow.com/a/21341372/372654
  -- doesn't work with e.g. `entire contents`

  -- TODO: Switch to (the same) Wi-Fi before handoff

  tell application "System Events"
    keystroke "z" using {control down, command down}
    tell application process "AirBuddyHelper"
      -- return name of every window

      tell window "Magic Handoff"
        -- return entire contents

        tell group 1
          repeat until exists
          end repeat

          -- return entire contents
          if op is not "send" then
            key code 124 -- Right arrow to select "Receive"
          end if

          keystroke return -- Proceed
          keystroke return -- The only other MacBook should be selected, proceed

          -- return entire contents
          tell scroll area 1
            -- return every static text
            -- return count of static texts

            -- AirBuddy only supports Apple devices
            repeat with i from 1 to (count of static texts)
              if value of static text i contains "Magic" then
                click checkbox i
              end if
            end repeat
            -- return
          end tell

          click button 1 -- Click "Send"
        end tell
      end tell
    end tell
  end tell
end run
