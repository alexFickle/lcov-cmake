# Wrapper arround genhtml.
#
# Arguments:
# INFO_DIR: Directory containing output from lcov for every target.
# OUTPUT_DIR: Directory to place html output.
# TITLE: Title passed to genhtml.

cmake_minimum_required(VERSION 3.19)

file(GLOB info_files ${INFO_DIR}/*)
list(LENGTH info_files num_info_files)
if(num_info_files EQUAL 0)
    message(
        "Error: No targets with code coverage enabled. \n"
        "  Did you forget to call lcov_enable() in your CMakeLists.txt? \n"
        "  Error also possible if calling lcov failed. \n"
        "  Look at output of previous build steps for errors from lcov."
    )
    return()
endif()

set(valid_info_files)
set(not_ran_targets)
set(filtered_targets)
foreach(file ${info_files})
    get_filename_component(target ${file} NAME)
    file(SIZE ${file} size)
    if(size EQUAL 0)
        list(APPEND not_ran_targets ${target})
    else()
        file(STRINGS ${file} sf_entry REGEX "^SF:" LIMIT_COUNT 1)
        if(sf_entry)
            list(APPEND valid_info_files ${file})
        else()
            list(APPEND filtered_targets ${file})
        endif()
    endif()
endforeach()

list(LENGTH not_ran_targets length)
if(NOT (length EQUAL 0))
    string(JOIN ", " targets ${not_ran_targets})
    message(
        "Warning: ${length} target(s) contain no executed translation units. \n"
        "  Did you forget to run some or all tests? \n"
        "  target(s): ${targets}"
    )
endif()

list(LENGTH filtered_targets length)
if(NOT (length EQUAL 0))
    string(JOIN ", " targets ${filtered_targets})
    message(
        "Warning: ${length} target(s) only contain executed code filtered "
        "  out by the INCLUDE and/or EXCLUDE arguments to lcov_enable(). \n"
        "  target(s): ${targets}"
    )
endif()

list(LENGTH valid_info_files length)
if(length EQUAL 0)
    message(
        "Error: No code coverage collected.  See above warnings."
    )
    return()
endif()

execute_process(
    COMMAND genhtml
        --output-directory ${OUTPUT_DIR}
        --demangle-cpp
        --title ${TITLE}
        ${valid_info_files}
)
