cask "immich-desktop" do
  version "2.0.0"
  sha256 "10db73173f2737e1230c18cb573e62a62dc2ee40d928f4bca85441d9e1a4e1aa"

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
