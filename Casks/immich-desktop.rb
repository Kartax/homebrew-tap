cask "immich-desktop" do
  version "1.6.2"
  sha256 "3ba6a7b6d184cd1b25f98613657cbce69a0a5476a28f3f756d75fc8068896e29"

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
