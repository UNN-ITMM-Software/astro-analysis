set(target ${ASTROCYTES_LIBRARY})

FILE(GLOB hdrs "*.h*" "${ASTROCYTES_INCLUDE}/*.h*")
FILE(GLOB srcs "*.cpp")

ADD_LIBRARY(${target} STATIC ${srcs} ${hdrs})
TARGET_LINK_LIBRARIES(${target} ${LIBRARY_DEPS})

# copy static library to the binary directory
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_BINARY_DIR}/\$\(Configuration\)"
        "${CMAKE_CURRENT_BINARY_DIR}/../../bin")