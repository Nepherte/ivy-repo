@echo off
setlocal EnableDelayedExpansion

:: Make sure Ant exists.
if "%ANT_HOME%" == "" (
  goto :printHelp
)

:: Parse optional arguments.
if %1 == -h (
  goto :printHelp
)
if %1 == --help (
  goto :printHelp
)

:: Script arguments.
set antTarget=%1
set artifact=%2

:: Validate mandatory arguments.
set argCount=0
for %%i in (%*) do set /a argCount+=1

if not %argCount% == 2 (
    goto :printHelp
)

if not %antTarget% == resolve (
if not %antTarget% == install (
if not %antTarget% == publish (
    goto :printHelp
) ) )

:: Init loop variables.
set artifactIndex=0
set artifactRemaining=%artifact%

:parseArtifactLoop
for /f "tokens=1* delims=:" %%a in ("%artifactRemaining%") do (
  if !artifactIndex! == 0 (
    set organisation=%%a
  )
  if !artifactIndex! == 1 (
    set module=%%a
  )
  if !artifactIndex! == 2 (
    set revision=%%a
  )
  
  set artifactRemaining=%%b
  set /a artifactIndex+=1
)

if not "!artifactRemaining!" == "" (
  goto :parseArtifactLoop
)

if not !artifactIndex! == 3 (
    goto :printHelp
)

:callAntTask
set callerDir="%CD%"
set antProperties=-Dorganisation=!organisation! -Dmodule=!module! -Drevision=!revision!
cd "%~dp0" && "%ANT_HOME%"\bin\ant.bat %antProperties% -f build.xml %antTarget%
cd "%callerDir%"
goto :end

:printHelp
echo Usage: IvyRepo.bat [-h] ^<command^> ^<artifact^>
echo Script to manage the Nepherte Ivy Repository.
echo.
echo    -h,--help    Print this help message
echo    ^<command^>    Possible values are resolve, install and publish
echo    ^<artifact^>   The artifact id as organisation:module:revision
echo.
echo.
echo Below are a couple of valid usage statements:
echo.
echo    Example 1: Download and build ivy artifact
echo    ^> IvyRepo.bat resolve org.slf4j:slf4j-api:1.7.21
echo.
echo    Example 2: Install ivy artifact to local repo
echo    ^> IvyRepo.bat install org.slf4j:slf4j-api:1.7.21
echo.
echo    Example 3: Publish ivy artifact to online repo
echo    ^> IvyRepo.bat publish org.slf4j:slf4j-api:1.7.21
echo.
echo.
echo The system variable ANT_HOME must point to the installation directory of
echo Apache Ant. In addition, a Java Runtime Environment must be installed too.

:end