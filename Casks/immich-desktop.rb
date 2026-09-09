cask "immich-desktop" do
  version "1.6.1"
  sha256 "7585c725ecc292054d61c583065f83fb2a8e7aac6602d09426563ccc98e0343a"

  url "https://github.com/Kartax/immich-desktop-app/releases/download/v#{version}/ImmichDesktop.dmg"
  name "Immich Desktop"
  desc "Browse a self-hosted Immich photo library in Finder"
  homepage "https://kartax.github.io/immich-desktop-app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "ImmichDesktop.app"

  uninstall quit: "org.kartax.ImmichDesktop"

  zap trash: "~/Library/Group Containers/group.org.kartax.ImmichDesktop"
end
