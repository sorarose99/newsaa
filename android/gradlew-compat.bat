@if "%DEBUG%"=="" @echo off
setlocal enabledelayedexpansion

REM Check for compatible Java versions
set "JAVA_COMPATIBLE="
for %%V in (21 17 11) do (
    where java.exe >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=2" %%A in ('java -version 2^>^&1 ^| findstr /R "version"') do (
            set "JAVA_VER=%%A"
            if "!JAVA_VER:~1,2!"=="%%V" (
                set "JAVA_COMPATIBLE=true"
                goto :java_found
            )
        )
    )
)

:java_found
if not defined JAVA_COMPATIBLE (
    echo Java 25 is too new for Gradle/Kotlin. Please install Java 21, 17, or 11 LTS
    echo Visit: https://www.oracle.com/java/technologies/downloads/
    exit /b 1
)

REM Run gradlew with the current Java
"%~dp0gradlew.bat" %*
