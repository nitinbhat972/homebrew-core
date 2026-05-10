class Ipsw < Formula
  desc "Research tool for iOS & macOS devices"
  homepage "https://blacktop.github.io/ipsw"
  url "https://github.com/blacktop/ipsw/archive/refs/tags/v3.1.679.tar.gz"
  sha256 "2406e1f52a96c945814447cbf6d9b1b37d1fbd81d4a16be147652cdf6819b94e"
  license "MIT"
  head "https://github.com/blacktop/ipsw.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f4ac5d72f4e3a3e363274c2f2f2e102bba1929fdc67ddec5b66d8faf8f48a985"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1ad1302e76856eb4e491626a1863dff65fc226e5965538a7198ef0ec951dd9a9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b4ac23df170909088557d59d5fc77c56d58bdac300669f72313928a52e96241d"
    sha256 cellar: :any_skip_relocation, sonoma:        "5f422657527cbfe2fa897ae1f3629b9462a5a59aa33a39c0ee7034ab486b5da1"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "f8d80e31585790514af4718154207875466ceb492e0adfc98aad6d9077a19d71"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a3dd9ea9fde30e98e31258f9dc5fb90a0a31e0cced57a2bdc4bb08517660a10c"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -s -w
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=#{version}
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/ipsw"
    generate_completions_from_executable(bin/"ipsw", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ipsw version")

    assert_match "iPad Pro (12.9-inch) (6th gen)", shell_output("#{bin}/ipsw device-list")
  end
end
