@echo off

if "%~1" == "" (
    echo.Usage: %~n0 STRING
    goto :EOF
)

setlocal

call :rus2lat x3 "%~1"
call :lat2rus x4 "%~1"

echo.rus2lat=%x3%
echo.lat2rus=%x4%

endlocal
goto :EOF


:rus2lat
if "%~2" == "" (
    set %~1=
    goto :EOF
)

call :translate RUS "%~1" "%~2"
goto :EOF


:lat2rus
if "%~2" == "" (
    set %~1=
    goto :EOF
)

call :translate RUS "%~1" "%~2" 1
goto :EOF


::: RUS � shh
::: RUS � sh
::: RUS � ch
::: RUS � kh
::: RUS � jj
::: RUS � jo
::: RUS � zh
::: RUS � eh
::: RUS � ju
::: RUS � ja
::: RUS � ''
::: RUS � '
::: RUS � a
::: RUS � b
::: RUS � v
::: RUS � g
::: RUS � d
::: RUS � e
::: RUS � z
::: RUS � i
::: RUS � k
::: RUS � l
::: RUS � m
::: RUS � n
::: RUS � o
::: RUS � p
::: RUS � r
::: RUS � s
::: RUS � t
::: RUS � u
::: RUS � f
::: RUS � c
::: RUS � y

::: RUS � Shh
::: RUS � Sh 
::: RUS � Ch 
::: RUS � Kh 
::: RUS � Jj 
::: RUS � Jo 
::: RUS � Zh 
::: RUS � Eh 
::: RUS � Ju 
::: RUS � Ja 
::: RUS � '' 
::: RUS � '  
::: RUS � A  
::: RUS � B  
::: RUS � V  
::: RUS � G  
::: RUS � D  
::: RUS � E  
::: RUS � Z  
::: RUS � I  
::: RUS � K  
::: RUS � L  
::: RUS � M  
::: RUS � N  
::: RUS � O  
::: RUS � P  
::: RUS � R  
::: RUS � S  
::: RUS � T  
::: RUS � U  
::: RUS � F  
::: RUS � C  
::: RUS � Y  

