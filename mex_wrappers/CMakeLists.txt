# get all cpp-files in current directory
file(GLOB mex_function_list RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.cpp)

set(MEX_DEF_FILE "mexFunction.def")

foreach(mex_function_filename ${mex_function_list})
  # get file name without extension
  get_filename_component(mex_function ${mex_function_filename} NAME_WE)

  # add and configure executable file to be produced
  matlab_add_mex(
      NAME ${mex_function}
      SRC ${mex_function_filename} ${MEX_DEF_FILE}
      LINK_TO ${ASTROCYTES_LIBRARY} ${LIBRARY_DEPS}
  )
endforeach()
