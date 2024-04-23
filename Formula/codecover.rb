class Codecover < Formula
    desc "Generate code coverage report in `lcov` format for multiplatform projects"
    homepage "https://github.com/ciuliene/codecover"
    url "https://github.com/ciuliene/codecover/releases/download/1.0.0/codecover-v1.0.0.tar.gz"
    sha256 "71ed66948810c7464ec8755be17e4a4a714f4f8bb8cc481a20839885537697ba"
    license "MIT"

    def install
        bin.install "main.sh" => "codecover"
    end

    test do
        assert_match "v1.0.0", shell_output("#{bin}/codecover --version")
    end
end
