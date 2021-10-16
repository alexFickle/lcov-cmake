cmake_minimum_required(VERSION 3.19)

define_property(
    TARGET PROPERTY __lcov_enabled INHERITED
    BRIEF_DOCS
        "Internal property used to control what targets get code coverage reported."
    FULL_DOCS
        "Internal property used to control what targets get code coverage reported."
)
set_property(GLOBAL PROPERTY __lcov_enabled "NO")
define_property(
    TARGET PROPERTY __lcov_include INHERITED
    BRIEF_DOCS
        "Internal property used to control what files get code coverage reported."
    FULL_DOCS
        "Internal property used to control what files get code coverage reported."
)
define_property(
    TARGET PROPERTY __lcov_exclude INHERITED
    BRIEF_DOCS
        "Internal property used to control what files get code coverage reported."
    FULL_DOCS
        "Internal property used to control what files get code coverage reported."
)

set(__lcov_script_dir ${CMAKE_CURRENT_LIST_DIR}/scripts CACHE STRING "script dir")


# Gets a value, first looking for a cmake variable and
# then an environment variable.
#
# name: The name of the variable.
# output: Output variable set with the value of the variable.
# default: The default value to use if no value is found.
function(__lcov_get_var name output default)

    if(DEFINED ${name})
        set(${output} ${${name}} PARENT_SCOPE)
        return()
    endif()

    if(DEFINED ENV{${name}})
        set(${output} $ENV{${name}} PARENT_SCOPE)
        return()
    endif()

    set(${output} ${default} PARENT_SCOPE)

endfunction()


# Gets a list of all targets created with add_library or add_executable
# excluding IMPORTED, INTERFACE and ALIAS targets.
function(__lcov_list_targets output)
    # The directories to check, is appended with subdirs
    set(dir_list ${CMAKE_SOURCE_DIR})
    # The index of the directory currently being processed
    set(dir_index 0)
    # The targets found
    set(target_list)

    while(1)
        list(LENGTH dir_list length)
        if(length EQUAL dir_index)
            break()
        endif()

        list(GET dir_list ${dir_index} dir)
        
        # Add all targets
        get_property(targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
        foreach(target ${targets})
            get_property(type TARGET ${target} PROPERTY TYPE)
            if(
                (type STREQUAL "STATIC_LIBRARY") OR
                (type STREQUAL "MODULE_LIBRARY") OR
                (type STREQUAL "SHARED_LIBRARY") OR
                (type STREQUAL "OBJECT_LIBRARY") OR
                (type STREQUAL "EXECUTABLE")
            )
                list(APPEND target_list ${target})
            endif()
        endforeach()

        # Add all subdirectories, with deduplication.
        # Unsure if a subdir can be added multiple times (probably not).
        get_property(subdirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
        foreach(subdir ${subdirs})
            list(FIND dir_list ${subdir} index)
            if(index EQUAL -1)
                list(APPEND dir_list ${subdir})
            endif()
        endforeach()

        math(EXPR dir_index "${dir_index}+1")
    endwhile()

    set(${output} ${target_list} PARENT_SCOPE)
endfunction()

# Function that runs at the very end of configure time.
function(__lcov_deferred)
    __lcov_get_var(LCOV_COVERAGE_TARGET coverage_target coverage)
    __lcov_get_var(LCOV_CLEAN_TARGET clean_target coverage_clean)

    __lcov_list_targets(targets)
    foreach(target ${targets})
        get_target_property(enabled ${target} __lcov_enabled)
        if(enabled)
            get_target_property(binary_dir ${target} BINARY_DIR)
            set(object_dir ${binary_dir}/CMakeFiles/${target}.dir)
            set(output_file ${CMAKE_BINARY_DIR}/__lcov_tmp/${target})
            
            set(flags)
            get_target_property(includes ${target} __lcov_include)
            foreach(include ${includes})
                list(APPEND flags --include \"${include}\")
            endforeach()
            get_target_property(excludes ${target} __lcov_exclude)
            foreach(exclude ${excludes})
                list(APPEND flags --exclude \"${exclude}\")
            endforeach()

            # generate info file when the coverage target is ran
            add_custom_target(
                ${coverage_target}-${target}
                COMMAND
                    lcov -c -q
                    --directory ${object_dir}
                    --output-file ${output_file}
                    ${flags}
            )
            add_dependencies(${coverage_target} ${coverage_target}-${target})

            # remove code coverage info when either the target is rebuilt or
            # when the coverage clean target is ran
            add_custom_target(
                ${clean_target}-${target}
                COMMAND ${CMAKE_COMMAND} -E rm -f ${output_file}
                COMMAND lcov -z -q --directory ${object_dir}
            )
            add_dependencies(${clean_target} ${clean_target}-${target})
            add_dependencies(${target} ${clean_target}-${target})

            # add required compile and linker --coverage flag
            get_target_property(target_type ${target} TYPE)
            target_compile_options(${target} PUBLIC --coverage)
            target_link_libraries(${target} PUBLIC --coverage)
        endif()
    endforeach()
endfunction()

# Ran when this module is included.
function(__lcov_init)
    __lcov_get_var(LCOV_COVERAGE_TARGET coverage_target coverage)
    __lcov_get_var(LCOV_OUTPUT_DIR output_dir coverage)
    if(NOT (IS_ABSOLUTE ${output_dir}))
        set(output_dir "${CMAKE_BINARY_DIR}/${output_dir}")
    endif()
    __lcov_get_var(LCOV_CLEAN_TARGET clean_target coverage_clean)

    # register __lcov_deferred (with deduplication)
    set(id lcov_deferred__)
    cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} GET_CALL_IDS registered)
    list(FIND registered ${id} index)
    if(index EQUAL -1)
        cmake_language(DEFER
            DIRECTORY ${CMAKE_SOURCE_DIR}
            ID ${id}
            CALL __lcov_deferred
        )
    endif()

    # create top level target to create code coverage (with deduplication)
    if(NOT TARGET ${coverage_target})
        add_custom_target(${coverage_target}
            COMMAND ${CMAKE_COMMAND} -E rm -rf ${output_dir}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${output_dir}
            COMMAND
                ${CMAKE_COMMAND}
                -DINFO_DIR=${CMAKE_BINARY_DIR}/__lcov_tmp
                -DOUTPUT_DIR=${output_dir}
                -DTITLE=${CMAKE_PROJECT_NAME}
                -P ${__lcov_script_dir}/genhtml.cmake
        )
    endif()

    # create top level target to clean up code coverage (with deduplication)
    if(NOT TARGET ${clean_target})
        add_custom_target(${clean_target}
            COMMAND ${CMAKE_COMMAND} -E rm -rf ${output_dir}
            COMMAND ${CMAKE_COMMAND} -E rm -rf ${CMAKE_BINARY_DIR}/__lcov_tmp
            COMMAND ${CMAKE_COMMAND} -E make_directory
                ${CMAKE_BINARY_DIR}/__lcov_tmp
        )
    endif()

    # create working directory for code coverage
    set(working_dir ${CMAKE_BINARY_DIR}/__lcov_tmp)
    file(MAKE_DIRECTORY ${working_dir})

    # create output directory for code coverage
    file(MAKE_DIRECTORY ${output_dir})

endfunction()

__lcov_init()


function(lcov_enable)
    cmake_parse_arguments(arg "" "" "INCLUDE;EXCLUDE" ${ARGN})
    set(includes)
    foreach(include ${arg_INCLUDE})
        if(IS_ABSOLUTE ${include})
            list(APPEND includes ${include})
        else()
            list(APPEND includes ${CMAKE_CURRENT_SOURCE_DIR}/${include})
        endif()
    endforeach()

    set(excludes)
    foreach(exclude ${arg_EXCLUDE})
        if(IS_ABSOLUTE ${exclude})
            list(APPEND excludes ${exclude})
        else()
            list(APPEND excludes ${CMAKE_CURRENT_SOURCE_DIR}/${exclude})
        endif()
    endforeach()

    set_directory_properties(PROPERTIES
        __lcov_enabled "ON"
        __lcov_include "${includes}"
        __lcov_exclude "${excludes}"
    )
endfunction()
