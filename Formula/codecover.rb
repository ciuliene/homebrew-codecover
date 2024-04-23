class Codecover < Formula
    desc "Generate code coverage report in `lcov` format for multiplatform projects"
    homepage "https://github.com/ciuliene/codecover"
    url "https://github.com/ciuliene/homebrew-codecover/releases/download/1.0.6/codecover-v1.0.6.tar.gz"
    sha256 "24f5e30089ec391f9bdf672d0c9f4c8c529763d926b6c1e7ec3f56dedb3a8de3"
    license "MIT"

    def install
        bin.install "main.sh" => "codecover"
    end

    test do
        assert_match "v1.0.6", shell_output("#{bin}/codecover --version")
    end
end
