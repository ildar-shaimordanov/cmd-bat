:: USAGE:
::     which [-a] [--] name [...]
::
:: -a  Print all available matchings accordingly the description below.
::
:: For each of the names the script looks for and displays a doskey macro, 
:: the internal command information or the full path to the executable 
:: file in this order. The script doesn't mimic of the Unix command having 
:: the same name. It assumes specifics of the Windows command prompt. 
::
:: First of all, it looks for doskey macros because they have the higher 
:: priority in the prompt. The next step is a looking for internal 
:: commands from the known list of the commands. If the command is 
:: identified as internal the searching is stopped. 
::
:: If nothing has been found previously, the script continues searching of 
:: external commands in the current directory and the directories from the 
:: PATH environment. If no extension is specified, the PATHEXT variable is 
:: used for attempts to find the nearest filename corresponding the 
:: provided name. 
::
:: ENVIRONMENT:
::     PATH, PATHEXT
::
:: SEE ALSO:
::     DOSKEY /?
::     HELP /?
::     http://ss64.com/nt/
::
:: COPYRIGHTS
:: Copyright (c) 2010, 2014 Ildar Shaimordanov

@echo off

if "%~1" == "" (
	for %%p in ( powershell.exe ) do if not "%%~$PATH:p" == "" (
		"%%~$PATH:p" -NoProfile -NoLogo -Command "cat '%~f0' | where { $_ -match '^::' } | %% { $_ -replace '::', '' }"
		goto :EOF
	)
	for /f "usebackq tokens=* delims=:" %%s in ( "%~f0" ) do (
		if /i "%%s" == "@echo off" goto :EOF
		echo:%%s
	)
	goto :EOF
)

setlocal

set "which_all="

:which_opt_begin
set "which_opt=%~1"
if not defined which_opt goto :which_opt_end
if not "%which_opt:~0,1%" == "-" goto :which_opt_end
if "%~1" == "--" goto :which_opt_end

if /i "%~1" == "-a" set which_all=1
shift

goto :which_opt_begin
:which_opt_end

:which_arg_begin
if "%~1" == "" goto :which_arg_end

echo:%~1 | "%windir%\system32\findstr.exe" /v ": \ * ? ; /" >nul || (
	echo:%~n0: Name should not consist of drive, paths or wildcards>&2
	goto :which_arg_continue
)

for /f "tokens=1,* delims==" %%a in ( ' "%windir%\System32\doskey.exe" /MACROS ' ) do (
	if /i "%~1" == "%%a" (
		echo:%%a=%%b
		if not defined which_all goto :which_arg_continue
	)
)

for %%b in ( 
	ASSOC CALL CD CHDIR CLS COLOR COPY DATE DEL DIR ECHO 
	ENDLOCAL ERASE EXIT FOR FTYPE GOTO IF MD MKDIR MKLINK MOVE 
	PATH PAUSE POPD PROMPT PUSHD RD REM REN RENAME RMDIR SET 
	SETLOCAL SHIFT START TIME TITLE TYPE VER VERIFY VOL 
) do if /i "%~1" == "%%~b" (
	echo:"%~1" is internal
	goto :which_arg_continue
)

set "which_ext="
for %%x in ( "%PATHEXT:;=" "%" ) do if /i "%~x1" == "%%~x" set "which_ext=%%~x"

if defined which_ext (
	call :which_binary_here "%~1" && if not defined which_all goto :which_arg_continue
	call :which_binary_path "%~1" && if not defined which_all goto :which_arg_continue
)

for %%x in ( "%PATHEXT:;=" "%" ) do (
	call :which_binary_here "%~1%%~x" && if not defined which_all goto :which_arg_continue
)
for %%x in ( "%PATHEXT:;=" "%" ) do (
	call :which_binary_path "%~1%%~x" && if not defined which_all goto :which_arg_continue
)

:which_arg_continue

shift

goto :which_arg_begin
:which_arg_end

endlocal
goto :EOF


:which_binary_here
if not exist ".\%~1" exit /b 1
echo:.\%~1
exit /b 0


:which_binary_path
for %%p in ( "%PATH:;=" "%" ) do for %%q in ( "%%~fp" ) do if exist "%%~fq\%~1" (
	echo:%%~fq\%~1
	if not defined which_all exit /b 0
)
exit /b 1


rem EOF
