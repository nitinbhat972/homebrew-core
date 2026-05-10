class Enzyme < Formula
  desc "High-performance automatic differentiation of LLVM"
  homepage "https://enzyme.mit.edu"
  url "https://github.com/EnzymeAD/Enzyme/archive/refs/tags/v0.0.259.tar.gz"
  sha256 "ba77229b0e031bbdc53c3bd8f0a052a88234f3d311c376658ecf90d7739e66ab"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/EnzymeAD/Enzyme.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "fe4971a60a71839a8920382dd1a9c78266a0939b035591885a2c00bd91b67985"
    sha256 cellar: :any,                 arm64_sequoia: "25a8599678a4189ca0158be997fe380fc9351830ed1a37e2ff688ec1c78ab18d"
    sha256 cellar: :any,                 arm64_sonoma:  "11f31ecd20d27d286639c59eed0ab943e6925a2269cf44bb6e3eff31714d03f0"
    sha256 cellar: :any,                 sonoma:        "ab9bfbbb7e01a0fe2ec56622e8e4e936dd93b5c48ea06cbb88e58470d95c1bc1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "97aa68649fe18dc93a25a2129bd808d593ebb342d458333a8a95e255aff64ad7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e794bc91cba9831efbdebfc26ccdaa2e9effdb8119410107c5d98b2706500aac"
  end

  depends_on "cmake" => :build
  depends_on "llvm"

  def llvm
    deps.map(&:to_formula).find { |f| f.name.match?(/^llvm(@\d+)?$/) }
  end

  def install
    system "cmake", "-S", "enzyme", "-B", "build", "-DLLVM_DIR=#{llvm.opt_lib}/cmake/llvm", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      extern double __enzyme_autodiff(void*, double);
      double square(double x) {
        return x * x;
      }
      double dsquare(double x) {
        return __enzyme_autodiff(square, x);
      }
      int main() {
        double i = 21.0;
        printf("square(%.0f)=%.0f, dsquare(%.0f)=%.0f", i, square(i), i, dsquare(i));
      }
    C

    ENV["CC"] = llvm.opt_bin/"clang"

    plugin = lib/shared_library("ClangEnzyme-#{llvm.version.major}")
    system ENV.cc, "test.c", "-fplugin=#{plugin}", "-O1", "-o", "test"
    assert_equal "square(21)=441, dsquare(21)=42", shell_output("./test")
  end
end
