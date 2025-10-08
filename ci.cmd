REM filepath: c:\Users\Orest\Desktop\АПКС\csad2526KI404HutovychOrestBohdanovich10\ci.cmd
@echo off
setlocal enabledelayedexpansion

set "BUILD_DIR=build"
set "CONFIG=Release"

pushd "%~dp0" || goto :fatal

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%" || goto :fatal_pop1
pushd "%BUILD_DIR%" || goto :fatal_pop1

cmake .. -DCMAKE_BUILD_TYPE=%CONFIG%
if errorlevel 1 goto :fatal_pop2

cmake --build . --config %CONFIG%
if errorlevel 1 goto :fatal_pop2

ctest --build-config %CONFIG% --output-on-failure
if errorlevel 1 goto :fatal_pop2

echo CMake build and tests succeeded.
popd
popd
exit /b 0

:fatal_pop2
popd
:fatal_pop1
popd
:fatal
echo Build or tests failed.
exit /b 1