class KleinanzeigenBot < Formula
  desc "Command-line bot to publish, update, delete, republish, download and extend Kleinanzeigen listings"
  homepage "https://github.com/Second-Hand-Friends/kleinanzeigen-bot"
  license "AGPL-3.0-or-later"

  # 2025-05-15 is the last dated, non-rolling release tag upstream cut
  # ("last release before pydantic based schema validation was introduced").
  # Everything since then (the "latest"/"preview" tags) is force-moved by CI
  # on every merge, which is a poor fit for Homebrew's immutable url+sha256
  # model. This formula intentionally tracks the pinned 2025-05-15 release.
  version "2025-05-15"
  COMMIT = "e7a3d46d25365054116bd6d221bf78baaddb4d76".freeze

  on_arm do
    url "https://github.com/Second-Hand-Friends/kleinanzeigen-bot/releases/download/2025-05-15/kleinanzeigen-bot-darwin-arm64"
    sha256 "0edeb31e012f7c75d45a8fe86e4e4ce23b3d9d8db6df041c0ca94de5de8b9b8c"
  end

  on_intel do
    url "https://github.com/Second-Hand-Friends/kleinanzeigen-bot/releases/download/2025-05-15/kleinanzeigen-bot-darwin-amd64"
    sha256 "4cb50204a45bd46b7ef90ad0c4d4132d946dfa089dbb12f5f90a96a81580dde7"
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
      #{browser_note}
      This formula tracks the pinned "2025-05-15" release (commit #{COMMIT}),
      the last dated release before upstream switched to rolling "latest" /
      "preview" tags that are force-moved on every merge. Newer fixes and
      features are not included until upstream cuts another dated release.
    EOS
  end

  test do
    assert_match "kleinanzeigen-bot", shell_output("#{bin}/kleinanzeigen-bot version")
  end
end
