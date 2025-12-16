@echo off
:: 관리자 권한 체크
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 관리자 권한이 필요합니다. 관리자 권한으로 다시 실행합니다...
    powershell start -verb runas '%~f0'
    exit /b
)

setlocal

REM 사용자 홈 디렉토리
set "TARGET=%USERPROFILE%\.ideavimrc"

REM 심볼릭 링크 원본 경로
set "SOURCE=%USERPROFILE%\iCloudDrive\develop-settings\ideavim\.ideavimrc"

REM 기존 .ideavim이 있다면 삭제
IF EXIST "%TARGET%" (
    echo 기존 .ideavim 파일/폴더 삭제 중...
    rmdir /s /q "%TARGET%" 2>nul
    del /f /q "%TARGET%" 2>nul
)

REM 심볼릭 링크 생성
echo 심볼릭 링크 생성 중...
mklink "%TARGET%" "%SOURCE%"

REM 사용자 홈 디렉토리
set "TARGET=%USERPROFILE%\AppData\Local\nvim"

REM 심볼릭 링크 원본 경로
set "SOURCE=%USERPROFILE%\iCloudDrive\develop-settings\nvim"

REM 기존 nvim이 있다면 삭제
IF EXIST "%TARGET%" (
    echo 기존 nvim 파일/폴더 삭제 중...
    rmdir /s /q "%TARGET%" 2>nul
    del /f /q "%TARGET%" 2>nul
)

REM 심볼릭 링크 생성
echo 심볼릭 링크 생성 중...
mklink /D "%TARGET%" "%SOURCE%"

echo 완료되었습니다.
pause
