cmd /c start PowerShell -Command "Start-Process -FilePath 'C:\Program Files (x86)\Xming\Xming.exe' -ArgumentList ':0 -clipboard -multiwindow -ac'"
cmd /c start PowerShell -NoExit -Command "docker stop wps_docker; docker start -i wps_docker"
