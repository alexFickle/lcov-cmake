from conans import ConanFile, CMake, tools

class MyProject(ConanFile):
    name = "my_project"
    # by default no code coverage is done
    options = {"coverage": [None, "lcov"]}
    settings = "os", "arch", "compiler", "build_type"
    generators = "cmake"

    build_requires = "gtest/1.8.1@bincrafters/stable"

    def build_requirements(self):
        if self.options.coverage == "lcov":
            # only if coverage is enabled depend on lcov_cmake
            self.build_requires("lcov_cmake/0.1.0@fickle/testing")
    
    def build(self):
        cmake = CMake(self)
        cmake.verbose = True
        if self.options.coverage == "lcov":
            # tell our CMakeLists.txt to use the lcov.cmake script
            cmake.definitions["LCOV_ENABLED"] = True
        cmake.configure()
        cmake.build()
        if not tools.cross_building(self.settings):
            cmake.test(output_on_failure=True)
    
    def package_info(self):
        self.info.header_only()
