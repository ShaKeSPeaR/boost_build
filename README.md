Boost build
===========

**Description**

A simple .bat file for building Boost Library with MS Visual Studio. 
Support v100, v110, v110_xp toolsets.

On first step build Boost.Build (b2/bjam), after building finished run b2 with params.

**Remarks**

* Run this script from boost root directory.
* If you have multiple MSVS installation use MSVS Developer console from target version.
* This file builds only x86 version.

`b2` must be configured for your project. Default settings here is:
* static multithread debug and release library in stage mode
* exclude mpi library


**Usage**

*Step 0*: Download and unpack Boost, place boost_build.bat in root directory of boost.

*Step 1*: Configure `b2` params in bat file for your project (last .bat lines).

*Step 2*: launch `boost_build.bat`:

`boost_build.bat VS_toolset_ver [build cores count] [xp mode flag]`

* VS_toolset_ver - point to msvs toolset. 10 for MSVS2010, 11 for MSVS2012
* [build cores count] - number of PC cores uses for build. Number from 1 to N
* [xp mode flag] - using xp toolset for MSVS. Any value for enable XP mode

**Examples**

* `boost_build 11 4 1` - building with v110_xp toolset on 4 cores.
* `boost_build 11 2`   - building with v110 toolset on 2 cores.