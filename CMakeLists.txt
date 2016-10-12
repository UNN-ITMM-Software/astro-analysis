CMAKE_MINIMUM_REQUIRED(VERSION 3.3.1)

set(PROJECT_NAME astrocytes_analysis)
project(${PROJECT_NAME})

# Choose Debug/Release mode
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Set compiler flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE})

# Find dependencies:
#   - OpenCV
find_package(OpenCV COMPONENTS core highgui imgproc video REQUIRED)
if (NOT OpenCV_FOUND)
    message(WARNING "OpenCV library wasn't found")
endif()
include_directories(${OpenCV_INCLUDE_DIRS})
link_directories(${OpenCV_LIB_DIR})

#   - Matlab
find_package(Matlab REQUIRED)
if (NOT Matlab_FOUND)
    message(WARNING "Matlab wasn't found")
endif()
include_directories(${Matlab_INCLUDE_DIRS})

#   - Boost
set(Boost_USE_STATIC_LIBS ON) 
set(Boost_USE_MULTITHREADED ON) 
find_package(Boost COMPONENTS filesystem system REQUIRED)
if (NOT Boost_FOUND)
    message(WARNING "Boost library wasn't found")
endif()
include_directories(${Boost_INCLUDE_DIRS})
link_directories(${Boost_LIBRARY_DIR})

set(ASTROCYTES_LIBRARY ${PROJECT_NAME})
set(ASTROCYTES_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/astrocytes_library/include")
set(ASTROCYTES_TESTS   "test_${PROJECT_NAME}")

set(DBSCAN_LIBRARY dbscan)
set(DBSCAN_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/dbscan")

set(LIBRARY_DEPS ${OpenCV_LIBS}
                 ${Matlab_ENG_LIBRARY} ${Matlab_MEX_LIBRARY} ${Matlab_MX_LIBRARY}
				 ${Boost_LIBRARIES} ${DBSCAN_LIBRARY})

include_directories("${ASTROCYTES_INCLUDE}" "${DBSCAN_INCLUDE}")

# BUILD:
#   - library dbscan
add_subdirectory("3rdparty/dbscan")
#   - library
add_subdirectory("astrocytes_library/src")
#   - mex-files
add_subdirectory(mex_wrappers)
#   - Google Test Framework
add_subdirectory("3rdparty/gtest")
#   - tests
add_subdirectory(tests)

# REPORT
message(STATUS "")
message(STATUS "=========================================")
message(STATUS "General configuration for ${PROJECT_NAME}")
message(STATUS "=========================================")
message(STATUS "")
message(STATUS "Configuration:       ${CMAKE_BUILD_TYPE}")
message(STATUS "OpenCV build path:   ${OpenCV_DIR}")
message(STATUS "  Header files:      ${OpenCV_INCLUDE_DIRS}")
message(STATUS "  Library files:     ${OpenCV_LIB_DIR}")
message(STATUS "Matlab package path: ${Matlab_ROOT_DIR}")
message(STATUS "  Header files:      ${Matlab_INCLUDE_DIRS}")
message(STATUS "  Library files:     ${Matlab_MEX_LIBRARY}")
message(STATUS "                     ${Matlab_MX_LIBRARY}")
message(STATUS "                     ${Matlab_ENG_LIBRARY}")
message(STATUS "                     ${Matlab_LIBRARIES}")
message(STATUS "Boost build path:    ${BOOST_ROOT}")
message(STATUS "  Header files:      ${Boost_INCLUDE_DIRS}")
message(STATUS "  Library files:     ${Boost_LIBRARIES}")
message(STATUS "=========================================")
message(STATUS "")
