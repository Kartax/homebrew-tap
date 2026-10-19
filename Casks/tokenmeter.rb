cask "tokenmeter" do
  version "0.2.0"
  sha256 "20c6781206440207924f7a2377040695d98a321bcae56d7ba4b3da685b0cc894"

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
