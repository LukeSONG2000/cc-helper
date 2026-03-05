@echo off
powershell.exe -Command "& \"$env:USERPROFILE\.claude\tools\claude-code-notifications\play-sound.ps1\" \"$env:USERPROFILE\.claude\tools\claude-code-notifications\sounds\%~1.wav\""
