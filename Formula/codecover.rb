class Codecover < Formula
    desc "Generate code coverage report in `lcov` format for multiplatform projects"
    homepage "https://github.com/ciuliene/codecover"
    url "https://github.com/ciuliene/homebrew-codecover/releases/download/1.0.9/codecover-v1.0.9.tar.gz"
    sha256 "956346d4482757e3d2c5f5b84ac451624ea718244188aa30f38022e07c7d5a65"
    license "MIT"

    def install
        bin.install "main.sh" => "codecover"
    end

    test do
        assert_match "v1.0.9", shell_output("#{bin}/codecover --version")
    end
end
