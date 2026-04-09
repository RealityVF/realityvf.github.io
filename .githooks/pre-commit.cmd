@echo off
REM Pre-commit hook to automatically update lastmod in markdown files
REM Windows batch version

REM 获取今天日期 (YYYY-MM-DD)
for /f "tokens=1-3 delims=/-" %%a in ('date /t') do (
    set TODAY=%%a-%%b-%%c
)

REM 获取暂存区中修改的 .md 文件
for /f "delims=" %%F in ('git diff --cached --name-only --diff-filter=ACM ^| findstr "\.md$"') do (
    echo %%F | findstr /i "content\\" >nul
    if not errorlevel 1 (
        REM 检查文件第一行是否是 ---
        setlocal enabledelayedexpansion
        set "FILE=%%F"
        set /p FIRST_LINE= < "!FILE!"
        if "!FIRST_LINE!"=="---" (
            findstr /r "^lastmod:" "!FILE!" >nul
            if not errorlevel 1 (
                REM 更新已有的 lastmod
                powershell -Command "(Get-Content '!FILE!') -replace '^lastmod: .*', 'lastmod: %TODAY%' | Set-Content '!FILE!'"
            ) else (
                REM 在 date 字段后添加 lastmod
                powershell -Command "(Get-Content '!FILE!') -replace '^(date: .*)', '$1`r`nlastmod: %TODAY%' | Set-Content '!FILE!'"
            )
            git add "!FILE!"
        )
        endlocal
    )
)
