
CMake script that adds CMake targets to a project to generate code
coverage using lcov and genhtml.

## Supported Platforms

This is only tested on linux with gcc.
Clang support is planned.

## Dependencies

This project has several dependencies that are not currently pushed to any
public conan remotes.  To use this project you will need to build these locally
using `git clone` and `conan create . fickle/testing`.
* https://github.com/alexFickle/perl-conan-pkg
* https://github.com/alexFickle/lcov-conan-pkg

Then you will need to do the same clone and create for this project.

## Setup with Conan

Setting up your project to use this script with conan is a simple two
step process.

1. Add this package as a build_requires to your project.
You most likely want this build_requires to be conditional on an option
so your project may be built without code coverage.

### `conanfile.py`
```python
from conans import ConanFile, CMake, tools

class MyProject(ConanFile):
    name = "my_project"
    # by default no code coverage is done
    options = {"coverage": [None, "lcov"]}
    settings = "os", "arch", "compiler", "build_type"
    generators = "cmake"

    def build_requirements(self):
        if self.options.coverage == "lcov":
            # only if coverage is enabled depend on lcov_cmake
            self.build_requires("lcov_cmake/0.1.0@fickle/testing")
    
    def build(self):
        cmake = CMake(self)
        if self.options.coverage == "lcov":
            # tell our CMakeLists.txt to use the lcov.cmake script
            cmake.definitions["LCOV_ENABLED"] = True
        cmake.configure()
        cmake.build()
        if not tools.cross_building(self.settings):
            cmake.test(output_on_failure=True)
```

2. Include lcov in your main CMakeLists.txt and use `lcov_enable()`.
This will enable code coverage for your entire project.
You may also use the INCLUDE and EXCLUDE arguments to `lcov_enable()` to
select which files will be included in the final code coverage report.
By default everything is included, including external libraries' header files.
You most likely want to limit this.  The below example is a reasonable default.

### `CMakeLists.txt`
```cmake
cmake_minimum_required(VERSION 3.19)

project(my_project CXX)

# setup conan
include(${CMAKE_CURRENT_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

# conditionally enable coverage
option(LCOV_ENABLED "enables code coverage with lcov" OFF)
if(LCOV_ENABLED)
    include(lcov)
    # including every local file except ones from the test directory
    lcov_enable(INCLUDE ** EXCLUDE test/**)
endif()

# rest of CMakeLists.txt omitted
```

See the example directory for a full, working example of a library that
uses conan and this project to generate code coverage reports.


## Command Line Usage

The above setup creates two CMake targets for you to interact with.

<table>
<tr><th> Command Name <th> Description
<tr><td> coverage <td>  Generates a code coverage report.
<tr><td> coverage_clean
<td> Deletes the code coverage report and zeros all code coverage counters.
</table>

The coverage_clean command is rarely needed to be ran by a user.
There are internal targets that will automatically zero out code coverage
counters for targets that are rebuilt to prevent invalid and misleading
code coverage reports.

The main intention of the coverage_clean command is to allow a user to
zero out all counters and then run the tests and get an exact count
of how many times each line is ran.
Without the clean they will get the sum of all the times that line has
been ran during their development since the target containing the line
has been rebuilt.

Another intention of the coverage_clean command is to allow a user to
clear code coverage counters, run a single test, and then generate
code coverage for just that test.
This process is occasionally helpful for debugging and verifying tests.

### Example
```sh
# Setup the conan build with code coverage enabled.
# Code coverage outside of a build_type of Debug is rarely useful.
# Notice that we are specifying an additional generator: virtualenv.
$ conan install . -if build -o coverage=lcov -s build_type=Debug -g virtualenv
$ cd build
# Run the conan build which includes running unit tests.
$ conan build ..
# Setup your shell to be able to run cmake commands in the
# same environment that conan runs commands in.
# This activate.sh is generated by the virtualenv generator.
# It can be exited by sourcing deactivate.sh.
$ source activate.sh
# Generate a code coverage report for all unit tests.
(conanenv) $ cmake --build . --target coverage
# The code coverage report is now in the coverage directory.
(conanenv) $ ls coverage
```
