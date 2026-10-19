cask "tokenmeter" do
  version "0.1.2"
  sha256 "5b71d29c9e80244ec1eb279f176348df44e010dbdc9ad09d5f8d3ec37454a193"

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
