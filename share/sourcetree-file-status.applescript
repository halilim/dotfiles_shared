# https://github.com/azu/sourcetree-commit
on run argv
	set gitFolder to quoted form of (first item of argv)
	set filePath to second item of argv
	-- set gitFolder to "/Users/halil/Code/rails/"
	-- set filePath to "app/models/user.rb"

  -- display notification "argv: " & argv & ", gitFolder: " & gitFolder & ", filePath: " & filePath
	-- return

	do shell script "open -a SourceTree " & gitFolder
	tell application "Sourcetree"
		activate
		delay 1
		tell application "System Events"
			keystroke "1" using {command down}
			keystroke "f" using {command down}
			keystroke filePath
		end tell
	end tell
end run
