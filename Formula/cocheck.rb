# Formula source for the tap cocheck-ai/homebrew-tap. `scripts/release.sh` rewrites the `url` and `sha256` lines for the release and prints the copy
# command; do not edit those two by hand. The url is the npm registry tarball of the release, and sha256 is the hash of the exact file
# `npm pack` made (the one you then `npm publish`), so a published file that differs breaks every install. The formula installs from the tarball's contents.
class Cocheck < Formula
  desc "Shows what AI agents changed in your files, step by step"
  homepage "https://github.com/cocheck-ai/cocheck"
  url "https://registry.npmjs.org/cocheck/-/cocheck-0.4.0.tgz"
  sha256 "6297fa50be3d60f2c104016352e09469804acf25fa734eebb8a98457debe7ed1"
  license "MIT"

  depends_on :macos
  depends_on "node"

  def install
    # The tarball unpacks to its package contents: bin/, dist/, public-kit/, scripts/hook-launch.sh and package.json (no lockfile, no src/).
    libexec.install "bin", "dist"
    # Code in dist/ resolves the connector kit from the package root (`connector create`'s starter, `connector test`'s toy states).
    # test/homebrew-installed-layout.slow.test.ts builds a libexec from this list and runs `connector create` and `connector test` in it.
    libexec.install "public-kit"
    (libexec/"scripts").install "scripts/hook-launch.sh"
    libexec.install "package.json"
    cd libexec do
      system "npm", "install", "--omit=dev", "--ignore-scripts", "--no-audit", "--no-fund"
    end

    # `cocheck` runs Homebrew's stable opt/node, so a node upgrade does not break it. The installer records
    # COCHECK_NODE and COCHECK_ROOT in the hook command: the same stable node, and a libexec that survives upgrades.
    (bin/"cocheck").write <<~SH
      #!/bin/sh
      export COCHECK_NODE="#{formula_opt_bin("node")}/node"
      export COCHECK_ROOT="#{opt_libexec}"
      exec "#{formula_opt_bin("node")}/node" "#{opt_libexec}/dist/cli-main.js" "$@"
    SH
  end

  def caveats
    <<~EOS
      Run `cocheck install --home <folder>` once to add CoCheck's hooks to your agent settings
      and choose the folder where CoCheck keeps its record. Then restart your agent.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cocheck --version")
    system bin/"cocheck", "connector", "create", testpath/"starter", "--id", "brew.test"
    assert_path_exists testpath/"starter/cocheck-connector.json"
    assert_match(/^passed$/, shell_output("#{bin}/cocheck connector test #{testpath}/starter"))
  end
end
