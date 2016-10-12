set(target ${DBSCAN_LIBRARY})

FILE(GLOB hdrs "*.h*" "${DBSCAN_INCLUDE}/*.h*")
FILE(GLOB srcs "*.cpp")

ADD_LIBRARY(${target} STATIC ${srcs} ${hdrs})
TARGET_LINK_LIBRARIES(${target} ${Boost_LIBRARIES})

# copy static library to the binary directory
add_custom_command(TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_BINARY_DIR}/\$\(Configuration\)"
        "${CMAKE_CURRENT_BINARY_DIR}/../../bin")