0</*! ::

::HELP Redirects output of command line tools to GUI application.
::HELP
::HELP
::HELP USAGE
::HELP
::HELP command | 2 [OPTIONS] [APP[.EXT] | EXT] [APP-OPTIONS]
::HELP
::HELP
::HELP OPTIONS
::HELP
::HELP -d DIR     use DIR for storing temp files
::HELP -n NAME    use NAME as the name of temp file
::HELP --debug    turn on debug information
::HELP --dry-run  don't invoke a command, display only
::HELP
::HELP
::HELP DESCRIPTION
::HELP
::HELP The script is flexible enough to enable many ways to invoke GUI 
::HELP applications. Which GUI application would be invoked is defined by 
::HELP the arguments. Depending on what is this, it will be called to 
::HELP declare few specific environment variables. 
::HELP
::HELP
::HELP INVOCATION
::HELP
::HELP commands | 2
::HELP
::HELP With no parameters runs Notepad. Always. 
::HELP
::HELP commands | 2 APP
::HELP
::HELP "APP" is the parameter defining an application or a family of 
::HELP applications or an extension (without the leading "dot" symbol). 
::HELP The script looks around for the file called as "2.APP.bat". If the 
::HELP file exists, invokes it to set the needful environment variables. 
::HELP The script should declare few specific environment variables (see 
::HELP the "ENVIRONMENT" section below). 
::HELP
::HELP commands | 2 APP.EXT
::HELP
::HELP The same as above but ".EXT" overrides early declared extension. 
::HELP
::HELP commands | 2 EXT
::HELP
::HELP If there is no file "2.APP.bat", the argument is assumed as the 
::HELP extension (without the leading "dor" symbol), the script does 
::HELP attempt to find an executable command (using "assoc" and "ftype") 
::HELP and prepare invocation of the command found by these commands. 
::HELP
::HELP
::HELP ENVIRONMENT
::HELP
::HELP %pipecmd%
::HELP
::HELP (Mandatory)
::HELP Invocation string for the application. It could or could not 
::HELP contain additional parameters supported by the application. 
::HELP
::HELP %pipeext%
::HELP
::HELP (Optional, but recommended to set)
::HELP Extenstion (like ".txt" or ".html" etc). It can be useful in the 
::HELP case if the application is able to handle different data files. 
::HELP
::HELP %pipetmpsave%
::HELP
::HELP (Optional)
::HELP The command line tool used for capturing the output of commands and 
::HELP redirecting to a resulting file. By default it is set as follows: 
::HELP
::HELP set "pipetmpsave=cscript //nologo //e:javascript "%~f0""
::HELP
::HELP You don't need to modify this variable, unless you need to specify 
::HELP another tool to capture input.
::HELP
::HELP
::HELP CONFIGURATION
::HELP
::HELP Using the file "2-settings.bat" located in the same directory 
::HELP allows to configure the global environment variables of the main 
::HELP script. It is good place for setting such kind of variables as 
::HELP %pipetmpdir%, %pipetmpname% and %pipetmpsave%. 
::HELP
::HELP
::HELP SEE ALSO
::HELP
::HELP ASSOC /?
::HELP FTYPE /?

:: ========================================================================

@echo off

timeout /t 0 >nul 2>&1 && (
	call :pipe-help
	goto :EOF
)

:: ========================================================================

setlocal

set "pipedbg="
set "pipedry="

set "pipetmpdir=%TEMP%"
set "pipetmpname=pipe.%RANDOM%"
set "pipetmpfile="
set "pipetmpsave=cscript //nologo //e:javascript "%~f0""

if exist "%~dpn0-settings.bat" call "%~dpn0-settings.bat"

set "pipecmd="
set "pipecmdopts="
set "pipetitle="
set "pipeext="

:: ========================================================================

:pipe-options-begin

if "%~1" == "" goto :pipe-options-end

if "%~1" == "-d" (
	set "pipetmpdir=%~2"
	shift /1
	shift /1
) else if "%~1" == "-n" (
	set "pipetmpname=%~2"
	shift /1
	shift /1
) else if "%~1" == "--debug" (
	set "pipedbg=1"
	shift /1
) else if "%~1" == "--dry-run" (
	set "pipedry=1"
	shift /1
) else (
	goto :pipe-options-end
)

goto :pipe-options-begin
:pipe-options-end

:: ========================================================================

if "%~1" == "" (

	rem command | 2

	set "pipecmd=notepad"
	set "pipetitle=[app = notepad]"
	set "pipeext=.txt"

) else if exist "%~dpn0.%~n1.bat" (

	rem command | 2 app[.ext]

	call :pipe-configure "%~dpn0.%~n1.bat" "%~x1"

	set "pipetitle=[app = %~n1]"
	if not defined pipeext set "pipeext=.%~n1"
	if not "%~x1" == "" set "pipeext=%~x1"

	shift /1

) else (

	rem command | 2 ext

	for /f "tokens=1,* delims==" %%a in ( '
		2^>nul assoc ".%~n1"
	' ) do for /f "tokens=1,* delims==" %%c in ( '
		2^>nul ftype "%%b"
	' ) do (

		set "pipecmd=%%d"
		set "pipetitle=[%%a = %%b]"
		set "pipeext=%%a"

	)
	if not "%~x1" == "" set "pipeext=%~x1"

	shift /1

)

if defined pipedbg call :pipe-debug "After parsing options"

:: ========================================================================

if not defined pipecmd (
	>&2 echo:Bad invocation
	goto :EOF
)

:: ========================================================================

if not defined pipeext set "pipeext=.txt"
if not defined pipetitle set "pipetitle=[%pipeext%]"

for %%f in ( "%pipetmpdir%" ) do set "pipetmpfile=%%~ff\%pipetmpname%%pipeext%"

:: ========================================================================

setlocal enabledelayedexpansion

set "pipecmdopt="

:pipe-app-options-begin
set pipecmdopt=%1
if not defined pipecmdopt goto :pipe-app-options-end

set "pipecmdopts=%pipecmdopts% %pipecmdopt%"
shift /1

goto :pipe-app-options-begin
:pipe-app-options-end

set "pipecmd=!pipecmd:%%1="%%1"!"
set "pipecmd=!pipecmd:""%%1""="%%1"!"
if "!pipecmd!" == "!pipecmd:%%1=!" set "pipecmd=!pipecmd! "%%1""
set "pipecmd=!pipecmd:%%1=%pipetmpfile%!"

endlocal & set "pipecmd=%pipecmd%" & set "pipecmdopts=%pipecmdopts%"

:: ========================================================================

if defined pipedbg call :pipe-debug "Before invocation"

call :pipe-invoke %pipecmdopts%

endlocal
goto :EOF

:: ========================================================================

:pipe-configure
setlocal
call "%~1" "%~2"
endlocal & set "pipecmd=%pipecmd%" & set "pipeext=%pipeext%" & set "pipetmpsave=%pipetmpsave%"
goto :EOF

:pipe-invoke
if defined pipedry (
	echo:Invocation ^(dry-run^)
	echo:call %pipetmpsave% ^> "%pipetmpfile%"
	echo:call start "Starting %pipetitle%" %pipecmd%
	goto :EOF
)

call %pipetmpsave% > "%pipetmpfile%"
call start "Starting %pipetitle%" %pipecmd%
goto :EOF

:: ========================================================================

:pipe-help
for /f "tokens=1,* delims= " %%a in ( '
	findstr /b "::HELP" "%~f0"
' ) do (
	echo:%%~b
)
goto :EOF

:pipe-debug
echo:%~1...
set pipe
echo:
goto :EOF

*/0;
WScript.StdOut.Write(WScript.StdIn.ReadAll());

// ========================================================================

// EOF
