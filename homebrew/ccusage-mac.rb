cask "ccusage-mac" do
  version "1.0.0"
  sha256 "PLACEHOLDER_SHA256"

  url "https://github.com/ssss-yajima/ccusage-mac/releases/download/v#{version}/CCUsageMac-#{version}.dmg"
  name "CCUsageMac"
  desc "Menu bar app that displays Claude Code usage costs"
  homepage "https://github.com/ssss-yajima/ccusage-mac"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: ">= :ventura"

  app "CCUsageMac.app"

  uninstall quit: "com.yajima.ccusage-mac"

  zap trash: [
    "~/Library/Preferences/com.yajima.ccusage-mac.plist",
    "~/Library/Application Support/CCUsageMac",
  ]
end