-- Default: https://github.com/matryer/xbar/blob/main/app/settings.go#L27 setDefaults()

set quotedScriptName to quoted form of "{{ .Command }}"
{{ if .Params }}
  set commandLine to {{ .Vars }} & " " & quotedScriptName & " " & {{ .Params }}
{{ else }}
  set commandLine to {{ .Vars }} & " " & quotedScriptName
{{ end }}

tell application "iTerm"
  if not running then
    activate
  end if

  tell current window
    tell current session
      repeat until exists
      end repeat

      delay 1
      write text commandLine
    end tell
  end tell
end tell
