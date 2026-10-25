# Mirage

A normal, sandboxed SwiftUI app. No jailbreak, no exploits, no system files touched.

Fake-OS UI: a lock screen (swipe up to unlock) and a home screen (icon grid, dock, long-press
to jiggle icons). Stretch sliders in Settings apply a scale transform to the *entire* fake-OS
surface, so it looks like the whole screen is being stretched. A Sileo-style tweak list in
Settings toggles icon shape, accent color, a tint overlay, haptics and a cosmetic "jailbroken"
badge - all of it only changes this app's own UI, nothing on the real system.

## Install

1. `git tag vX.Y.Z && git push --tags` - GitHub Actions (macOS runner) builds an **unsigned**
   `Mirage.ipa` and attaches it to the release.
2. Download the `.ipa` to your phone and open it with **LiveContainer** (no signing needed) or
   add it to **SideStore**.

## License

MIT, see LICENSE.
