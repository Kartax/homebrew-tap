cask "immich-desktop" do
  version "1.4.6"
  sha256 "0c5ac7c3b9b1e862694538e0796ff71aa3d0431555f48cc5f46b63de5fd5c32f"

  url "https://github.com/Kartax/immich-desktop-app/releases/download/v#{version}/ImmichDesktop.dmg",
      verified: "github.com/Kartax/immich-desktop-app/"
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
