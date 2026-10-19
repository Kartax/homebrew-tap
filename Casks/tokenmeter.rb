cask "tokenmeter" do
  version "0.1.1"
  sha256 "b1192497feeee69e3d40bb15a15061af70aa231f12f0d4f32358bbb061cbdb08"

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
