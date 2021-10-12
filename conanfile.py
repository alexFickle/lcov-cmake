from conans import ConanFile

class LcovCMakeConanFile(ConanFile):
    name = "lcov_cmake"
    version = "0.1.0"
    requires = "lcov/1.15@fickle/testing"
    exports = "LICENSE"
    exports_sources = "LICENSE", "cmake/*"

    def package(self):
        self.copy("*.cmake", src="cmake", dst=".")
        self.copy("LICENSE", src=".", dst="licenses")
