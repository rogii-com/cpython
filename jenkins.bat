@set ARTIFACTS_DIR_NAME=package
@set ENV_INSTALL=%CD%\%ARTIFACTS_DIR_NAME%

set _ARCH=amd64
set BUILD_ENV_SCRIPTS_PATH=D:\dev_cpp
set CNPM_ROOT=D:\dev_cpp\cnpm_cache
set CNPM_URLS=https://developer3:2uHwW7gJFxvQp5fJ0BrAHSgTYmNcIX@cnpm.rogii.com/windows/ebc92942-6729-4cc9-a254-9d3611c87b72


cmake -P %CD%\rogii\build\windows\jenkins_env\generate_setup_msvs_env.cmake

call setup_msvs_env.bat %_ARCH%
set

cmake -P rogii/build_%_ARCH%.cmake

if ERRORLEVEL 1 (
    echo Build package failed
    exit 1
)

echo Done