cask "tokenmeter" do
  version "0.1.3"
  sha256 "897420636291f662be5fa77a9c8c6c58b287664368a4a8caf01a7a02776dcebd"

  url "https://github.com/Kartax/tokenmeter/releases/download/v#{version}/TokenMeter.dmg"
  name "TokenMeter"
  desc "Menu bar meter for AI subscription quotas"
  homepage "https://kartax.github.io/tokenmeter/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "TokenMeter.app"

  uninstall quit: "org.kartax.TokenMeter"

  zap trash: [
    "~/Library/Application Support/TokenMeter",
    "~/Library/Preferences/org.kartax.TokenMeter.plist",
  ]
end
