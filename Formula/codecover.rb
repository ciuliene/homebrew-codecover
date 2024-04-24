class Codecover < Formula
    desc "Generate code coverage report in `lcov` format for multiplatform projects"
    homepage "https://github.com/ciuliene/codecover"
    url "https://github.com/ciuliene/homebrew-codecover/releases/download/1.0.7/codecover-v1.0.7.tar.gz"
    sha256 "4416a5a9aaf449628a78a1e4edae9820e90b24487a8e6da14dd39fa63ff81fb7"
    license "MIT"

    def install
        bin.install "main.sh" => "codecover"
    end

    test do
        assert_match "v1.0.7", shell_output("#{bin}/codecover --version")
    end
end
