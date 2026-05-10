class OhMyAgent < Formula
  desc "Portable multi-agent harness for .agents-based skills and workflows"
  homepage "https://github.com/first-fluke/oh-my-agent"
  url "https://registry.npmjs.org/oh-my-agent/-/oh-my-agent-7.3.1.tgz"
  sha256 "412d99bdd683d555e7260dc6d68d824a545208430241155b9c8a798db72864d8"
  license "MIT"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "a05728178f83eca0a08a53ac979991a1b0035511ccfce0c6d7ffa430313e18e3"
    sha256 cellar: :any,                 arm64_sequoia: "43383b030dbebd937cce617b9b65538ec50ddeae281c24f2b9a63cd239e5275f"
    sha256 cellar: :any,                 arm64_sonoma:  "43383b030dbebd937cce617b9b65538ec50ddeae281c24f2b9a63cd239e5275f"
    sha256 cellar: :any,                 sonoma:        "fae407271a34fdf77f7e765981547291717630baefd1e214a4d4505c660b5f7d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7fe71fc6f501544328cb7037bb26490e61915b58f4818bef8054855d1b8ae03e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d871fff1942fe65a7f4eb2735f6ef25087bb9d5c788d7bb062bfca68e20592a3"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args

    node_modules = libexec/"lib/node_modules/oh-my-agent/node_modules"
    # Remove incompatible pre-built `bare-fs`/`bare-os`/`bare-url` binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules.glob("{bare-fs,bare-os,bare-url}/prebuilds/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }

    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oh-my-agent --version")

    output = JSON.parse(shell_output("#{bin}/oh-my-agent memory:init --json"))
    assert_empty output["updated"]
    assert_path_exists testpath/".serena/memories/orchestrator-session.md"
    assert_path_exists testpath/".serena/memories/task-board.md"
  end
end
