This directory contains a simple library built by conan that can
get code coverage reports generated for its unit tests.

# Example CLI Usages

### Generating code coverage for all unit tests
```sh
$ conan install . -if build -o coverage=lcov -s build_type=Debug -g virtualenv
$ cd build
$ conan build ..
$ source activate.sh
(conanenv) $ cmake --build . --target coverage
(conanenv) $ ls coverage
```

## Generating code coverage for a single unit test
```sh
$ conan install . -if build -o coverage=lcov -s build_type=Debug -g virtualenv
$ cd build
$ conan build ..
$ source activate.sh
(conanenv) $ cmake --build . --target coverage_clean
(conanenv) $ bin/test_checked_add --gtest_filter=u8.overflow
(conanenv) $ cmake --build . --target coverage
(conanenv) $ ls coverage
```
