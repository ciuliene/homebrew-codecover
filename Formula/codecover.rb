class Codecover < Formula
    desc "Generate code coverage report in `lcov` format for multiplatform projects"
    homepage "https://github.com/ciuliene/codecover"
    url "https://github.com/ciuliene/codecover/releases/download/1.0.2/codecover-v1.0.2.tar.gz"
    sha256 "3ab7da7f125ccf4d0a6ca6372b6bfd349f72c7488435cefdb4af609965964023"
    license "MIT"

    def install
        bin.install "main.sh" => "codecover"
    end

    test do
        assert_match "v1.0.2", shell_output("#{bin}/codecover --version")
    end
end
