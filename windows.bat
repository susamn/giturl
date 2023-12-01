@echo off

REM Function to extract URLs
:get_url
setlocal
set "option=%~1"
set "remote_url=%~2"
set "branch=%~3"

REM Normalize remote URL by removing leading/trailing spaces and slashes
set "remote_url=%remote_url: =%"
set "remote_url=%remote_url:/=%"

REM Extract provider from the remote URL
for %%P in (%remote_url%) do set "provider=%%~nxP"

if /I "%provider%"=="github.com" (
    if /I "%option%"=="-p" (
        set "url=https://github.com/%remote_url%/actions/workflows?query=branch%%3A%branch%"
    ) else if /I "%option%"=="-m" (
        set "url=https://github.com/%remote_url%/pulls?utf8=%%E2%%9C%%93&q=is%%3Apr+is%%3Aopen+head%%3A%branch%"
    ) else if /I "%option%"=="-r" (
        set "url=https://github.com/%remote_url%"
    ) else (
        echo Unknown option: %option%
    )
) else if /I "%provider%"=="gitlab.com" (
    if /I "%option%"=="-p" (
        set "url=https://gitlab.com/%remote_url%/-/pipelines?ref=%branch%"
    ) else if /I "%option%"=="-m" (
        set "url=https://gitlab.com/%remote_url%/-/merge_requests?scope=all&utf8=%%E2%%9C%%93&state=opened&search=%branch%"
    ) else if /I "%option%"=="-r" (
        set "url=https://gitlab.com/%remote_url%"
    ) else (
        echo Unknown option: %option%
    )
) else if /I "%provider%"=="bitbucket.org" (
    if /I "%option%"=="-p" (
        set "url=https://bitbucket.org/%remote_url%/addon/pipelines/home#!/results/%branch%"
    ) else if /I "%option%"=="-m" (
        set "url=https://bitbucket.org/%remote_url%/pull-requests?&src=recent&search=%branch%"
    ) else if /I "%option%"=="-r" (
        set "url=https://bitbucket.org/%remote_url%"
    ) else (
        echo Unknown option: %option%
    )
) else (
    echo Unsupported provider: %provider%
)

REM Open the URL in the default browser
if defined url (
    start "" "%url%"
) else (
    echo URL was not generated.
)
endlocal & exit /b

REM Get the remote URL of the Git repository
for /f "delims=" %%a in ('git config --get remote.origin.url') do set "remote_url=%%a"

REM Get the current branch
for /f "delims=" %%b in ('git symbolic-ref --short HEAD') do set "current_branch=%%b"

REM Parse options
:getoptions
if "%~1"=="" goto :end
set "opt=%~1"
shift
if /I "%opt%"=="-p" (
    call :get_url -p "%remote_url%" "%current_branch%"
) else if /I "%opt%"=="-m" (
    call :get_url -m "%remote_url%" "%current_branch%"
) else if /I "%opt%"=="-r" (
    call :get_url -r "%remote_url%"
) else (
    echo Unknown option: %opt%
)
shift
goto :getoptions

:end
