set(target ${ASTROCYTES_TESTS})

file(GLOB hdrs "*.h*")
file(GLOB srcs "*.cpp")

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../3rdparty/gtest" "${DBSCAN_INCLUDE}" "${ASTROCYTES_INCLUDE}")


add_executable(${target} ${srcs} ${hdrs})
target_link_libraries(${target} gtest ${ASTROCYTES_LIBRARY} ${DBSCAN_LIBRARY})
