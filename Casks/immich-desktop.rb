cask "immich-desktop" do
  version "1.6.0"
  sha256 "5e0765cc74eeb30e779ec4e137de20efe6adac6d31f5f09397e4e8e8f3789810"

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
