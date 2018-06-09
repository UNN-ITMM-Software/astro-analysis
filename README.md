# Software for astrocyte analysis

## Introduction

Implementation of a new method for astrocyte analysis. Method is based
on "sliding" window approach and include the following stages:

  1. **Video preprocessing**:
     - Aligning an image (eliminating jitter).
     - Calculating noise parameters and subtracting the camera noise.
     - Filtering video frames [BM3D][bm3d].
     - Evaluating a noise level on the filtered video.

  2. **Calculating a baseline** of the fluorescence intensity and its relative variation based on the noise information.
  3. **Detecting calcium events** based on the relative intensity variation.
  
## Project structure

Project consists of the following directories:

  1. `3rd_party` - third-party libraries is used in the project:
     
     - `dbscan` - DBScan implementation (not needed now, because faster implementation is used).
     - `gtest` - Google Testing Framework.
     - `bm3d` - BM3D implementation (follow steps in `3rd_party/bm3d/README` to get implementation).
     - `DataHash` - data hashing for internal use.
     - `plot_mk` - library for prettifying MATLAB plot.
     - `progress_bar` - GUI progress bar library.
     - `tabplot` - GUI tabs library.
     
  1. `astrocytes_library` - C++ library for astrocyte analysis.
  1. `auxiliary_scripts` - auxiliary scripts to analyze temporary data.
  1. `matlab_scripts` - matlab-scripts for researchers.
  1. `data` - directory with short test sample (`*z-max*.mat` - maximal projection),
     three-dimensional matrix `width*height*k`, where `width` is a frame width, `height`
     is a frame height, `k` is a number of frames.
  1. `mex_wrappers` - mex-functions (wrappers) for the library
     of astrocyte analysis.
  1. `tests` - automatic tests to check correctness of the algorithm.
   
## Prerequisites

Software for astrocyte analysis has several dependencies:

  1. MATLAB is required to read/write mat-files (version >= R2016a).
  1. Boost (version >= 1.60), 
     [binaries for Windows][boost-win-bin].
  1. [OpenCV][opencv] (version 2.4.*).
  1. [BM3D][bm3d-archive] is required for filtering frames (follow steps described 
     in `3rd_party/bm3d/README`).

Environment:

  1. Windows
     - [CMake][cmake] (version >=3.1.0).
     - C++ Compiler (for example, Visual C++ Compiler from Microsoft Visual Studio 2013,
       2015 is preferable).
  1. Linux
     - [CMake][cmake] (version >=3.1.0).
     - C++ Compiler (for example, GCC >= 4.7).

## How to build

### Windows (Visual C++ Compiler)

  1. Install prerequisites.
  1. Download [source code][astro-repo].
  1. Open Command Prompt Window (use [this][cmd] manual).
  1. Create build directory `astro-events-analysis-build` next 
     to the directory `astro-events-analysis` using the following
     command:
  
     ```bash
     mkdir astro-events-analysis-build
     ```
  
  1. Set `astro-events-analysis-build` as current directory using the following
     command:
  
     ```bash
     cd astro-events-analysis-build
     ```
  
  1. Generate Visual Studio solution to compile sources using the following
     command. Note: if Boost library installed from binaries you must
     set `BOOST_ROOT`, `Boost_INCLUDE_DIRS` and `Boost_LIBRARY_DIR`.
  
     ```bash
     cmake -G <Generator-name>
           -DOpenCV_DIR=<OpenCVConfig.cmake-directory>
           [-DBOOST_ROOT=<Boost-library-directory>]
           [-DBoost_INCLUDE_DIRS=<dir-with-boost-header-files>]
           [-DBoost_LIBRARY_DIR=<dir-with-boost-lib-files>]
           [-DMATLAB_ROOT=<matlab-dir>]
           -DMatlab_MX_LIBRARY="<dir-with-libmx>\libmx.lib"
           -DMatlab_ENG_LIBRARY="<dir-with-libeng>\libeng.lib"
           ..\astro-events-analysis
     ```
  
     Example:
     ```bash
     cmake -G "Visual Studio 14 2015 Win64" -DOpenCV_DIR="c:\Program Files\opencv2411\vs2015" 
         -DBOOST_ROOT="c:\boost_1_60_0" 
         -DBoost_INCLUDE_DIRS="c:\boost_1_60_0\boost" 
         -DBoost_LIBRARY_DIR="c:\boost_1_60_0\lib64-msvc-14.0" 
         -DMATLAB_ROOT="c:\Program Files\MATLAB\R2010a"
         -DMatlab_MX_LIBRARY="c:\Program Files\MATLAB\R2010a\extern\lib\win64\microsoft\libmx.lib" 
         -DMatlab_ENG_LIBRARY="c:\Program Files\MATLAB\R2010a\extern\lib\win64\microsoft\libeng.lib" 
         ..\astro-events-analysis
     ```
  
  1. Choose Release and x64 modes in main menu of Visual Studio.
  
  1. Choose project `ALL_BUILD` and execute command `Rebuild` in the menu that you get
     after right mouse click. You will see static libraries `astrocytes_analysis.lib`,`dbscan.lib`,
     3 mex-wrappers (`preprocessing.mexw64`, `background_subtraction.mexw64`, `find_events.mexw64`),
     and binary file `test_astrocytes_analysis.exe` (contains some automatic tests for developers)
     in the directory `astro-events-analysis-build\bin`.

## How to run

Detailed user's guide located in `matlab_scripts/README`.

<!-- LINKS -->

[backgroundsubtractormog2]: http://docs.opencv.org/2.4.12/modules/video/doc/motion_analysis_and_object_tracking.html#backgroundsubtractormog2
[bm3d]: http://www.cs.tut.fi/~foi/GCF-BM3D
[bm3d-archive]: http://www.cs.tut.fi/~foi/GCF-BM3D/BM3D.zip
[opencv]: http://opencv.org
[cmd]: http://windows.microsoft.com/en-us/windows-vista/open-a-command-prompt-window
[astro-repo]: https://github.com/UNN-VMK-Software/astro-events-analysis
[boost-win-bin]: https://sourceforge.net/projects/boost/files/boost-binaries
[cmake]: https://cmake.org/download