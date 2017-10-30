cmd /c start PowerShell -Command "docker stop R_studio; docker start R_studio; ; Start-Process 'chrome.exe' -ArgumentList 'http://localhost:8787'"
