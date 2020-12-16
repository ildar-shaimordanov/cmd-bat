@echo off

set "HOME=%TEA_HOME%\home"

for /d %%d in (
	"%~dp0..\vendors\xsrv"
	"%~dp0..\vendors\VcXsrv*"
	"%~dp0..\vendors\Xming*"
) do if exist "%%~d" for %%n in (
	XLaunch
) do if exist "%%~d\%%~n.exe" (
	start "" "%%~d\%%~n.exe" -run "%~dp0..\etc\xsrv\xsrv-multiwindow.xlaunch"
	goto :EOF
)

echo:X server not found>&2
