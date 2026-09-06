class KleinanzeigenBotPreview < Formula
  desc "Command-line bot to publish, update, delete, republish, download and extend Kleinanzeigen listings (preview channel)"
  homepage "https://github.com/Second-Hand-Friends/kleinanzeigen-bot"
  license "AGPL-3.0-or-later"

  # Upstream ships pre-built, self-contained PyInstaller binaries and moves
  # the "preview" tag forward on every merge to main instead of cutting
  # SemVer releases (see https://github.com/Second-Hand-Friends/kleinanzeigen-bot/releases).
  # We therefore pin the sha256 of whatever "preview" currently points to;
  # bump `version` and both `sha256`s when upstream publishes a new build.
  version "2026+37c7f52"

  on_arm do
    url "https://github.com/Second-Hand-Friends/kleinanzeigen-bot/releases/download/preview/kleinanzeigen-bot-darwin-arm64"
    sha256 "2f22a7b918f796b3d3c583fc29f6461248e039706c53a73f118cc283f3b01f7c"
  end

  on_intel do
    url "https://github.com/Second-Hand-Friends/kleinanzeigen-bot/releases/download/preview/kleinanzeigen-bot-darwin-amd64"
    sha256 "3098dc7fe7e7edf2647e7c8e14fc5c8be66791650ba784670f26005e325ce176"
  end

  depends_on :macos

  def install
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    bin.install "kleinanzeigen-bot-darwin-#{arch}" => "kleinanzeigen-bot"
  end

  # Homebrew has no built-in "any of these casks" dependency: `depends_on`
  # is always AND, and Chrome/Chromium/Edge are casks, not formulae, so we
  # can't express "one of the following" declaratively. Best we can do is
  # check well-known install locations at caveats-time and only warn if
  # none of them is present.
  def detected_chromium_browser
    app_dirs = ["/Applications", "#{Dir.home}/Applications"]
    app_names = ["Google Chrome.app", "Chromium.app", "Microsoft Edge.app"]
    app_dirs.each do |dir|
      app_names.each do |name|
        return name if File.exist?("#{dir}/#{name}")
      end
    end
    nil
  end

  def caveats
    browser_note = if (found = detected_chromium_browser)
      "Detected #{found} - good to go."
    else
      <<~EOS
        ⚠️  No Chromium-based browser found in /Applications.
        kleinanzeigen-bot requires one of:
          - Google Chrome
          - Chromium
          - Microsoft Edge
        Install one, e.g.: brew install --cask google-chrome
      EOS
    end

    <<~EOS
      This is the PREVIEW channel of kleinanzeigen-bot (pre-release builds
      from the "preview" tag). For the stable channel, install the
      `kleinanzeigen-bot` formula instead.

      #{browser_note}
      Because upstream does not tag SemVer releases and instead force-moves
      the "preview" release to the newest build, this formula can go stale.
      Check for a newer build with:
        kleinanzeigen-bot version
      and compare against the commit referenced at:
        https://github.com/Second-Hand-Friends/kleinanzeigen-bot/releases/tag/preview
    EOS
  end

  test do
    assert_match "kleinanzeigen-bot", shell_output("#{bin}/kleinanzeigen-bot version")
  end
end
