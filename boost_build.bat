@echo off
setlocal enabledelayedexpansion


REM === DESCRIPTION ===========================================================
REM Bat file for build Boost Libraries from scratch.
REM On first step build Boost.Build (b2/bjam),
REM after building finished run b2 with params.

REM === REMARMKS ==============================================================
REM  - If you have multiple MSVS installation use MSVS Developer console
REM    from target version
REM  - This file builds only x86 version
REM  - Run this script from boost root directory

REM === USAGE =================================================================

REM  boost_build.bat VS_toolset_ver [build cores count] [xp mode flag]

REM  VS_toolset_ver - point to msvs toolset. 10 for MSVS2010, 11 for MSVS2012 or 14 for MSVS2015
REM  [build cores count] - number of PC cores uses for build. Number from 1 to N
REM  [xp mode flag] - using xp toolset for MSVS (only for VS 10 or 11). Any value for enable XP mode

REM === EXAMPLES ==============================================================
REM   boost_build 11 4 1 - building with v110_xp toolset on 4 cores.
REM   boost_build 11 2   - building with v110 toolset on 2 cores.
REM ===========================================================================


::setup working dir and vars
set WORK_DIR=%~dp0

set MSVC_VER=%1
set USED_CORES=%2
set XP_TOOSET_ENABLE=%3

::check input params
if "%MSVC_VER%" == "" (
    echo FAIL: MS VS toolset version needed [10,11 or 14]
    echo Usage: boost_build.bat VS_toolset_ver [build cores count] [xp mode flag]
    echo   - VS_toolset_ver - point to msvs toolset. 10 for MSVS2010, 11 for MSVS2012, 14 for MSVS2015
    echo   - [build cores count] - number of PC cores uses for build. Number from 1 to N. Def - 2
    echo   - [xp mode flag] - using xp toolset for MSVS. Any value for enable XP mode
    echo    
    echo Examples: boost_build 11 4 1 - building with v110_xp toolset on 4 cores.
    echo           boost_build 11 2   - building with v110 toolset on 2 cores.
    exit /b 1
)

if not "%MSVC_VER%" == "10" (
    if not "%MSVC_VER%" == "11" (    
        if not "%MSVC_VER%" == "14" (    
            echo FAIL: MS VS wrong format. Need - 10, 11 or 14
            exit /b 1
        )
    )
)

::default - 2 cores
if "%USED_CORES%" == "" set USED_CORES=2

::caption and defines for v110_xp toolset
set XP_TOOSET_CAPTION=Win 7+
set XP_TOOLSET_DEFINES=

::standalone check MSVS12 and setup variables
if "%MSVC_VER%" == "11" call "%ProgramFiles(x86)%\Microsoft Visual Studio 11.0\VC\bin\vcvars32.bat"

::check and setup XP mode 
::useful info from Microsoft: http://blogs.msdn.com/b/vcblog/archive/2012/10/08/10357555.aspx
if "%MSVC_VER%" == "11" (
  
    ::toolset caption
    set XP_TOOSET_CAPTION=Win 7+

    if not "%XP_TOOSET_ENABLE%" == "" (    
        
        ::system settings
        set "INCLUDE=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Include;%INCLUDE%"
        set "PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Bin;%PATH%"
        set "LIB=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Lib;%LIB%"
        
        ::cl and linker settings
        set "CL=/D_USING_V110_SDK71_ %CL%"
        set "LINK=/SUBSYSTEM:CONSOLE,5.01 %LINK%"

        ::XP toolset defines
        set XP_TOOLSET_DEFINES=define=WINVER=0x0501 define=_WIN32_WINNT=0x0501 ^
define=NTDDI_VERSION=0x05010000 define=PSAPI_VERSION=1
        
        set XP_TOOSET_CAPTION=Win XP
    )
)

echo ==============================================================================
echo Prepare for build.... Using MSVS-%MSVC_VER%.0 (%XP_TOOSET_CAPTION%) and %USED_CORES% cores for build

echo Try to build boost build system....
echo ==============================================================================

::building Boost build system
call bootstrap.bat

echo ==============================================================================
echo Building boost - static multithread debug and release in stage mode
echo Output - "last_boost_stage" and "last_boost_build" in work dir
echo ==============================================================================

::build boost libraries 
::launch string breaks for 3 lines:
:: - base params (build dir, toolset, stage dir, etc)    
:: - libraries for exclude
:: - compiler params (variants, link type, threading, etc )
b2 -j %USED_CORES% --build-dir=%WORK_DIR%last_boost_build toolset=msvc-%MSVC_VER%.0 --stagedir=%WORK_DIR%last_boost_stage stage ^
   --without-mpi ^
   variant=debug,release link=static threading=multi runtime-link=shared %XP_TOOLSET_DEFINES%
