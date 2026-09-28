# Screenshot gallery

These are screenshots of Vesta’s actual SwiftUI/AppKit interface, captured for
version 0.2.0. All rooms, light names and states are simulated. No bridge, Bluetooth
connection or saved credentials are used by the preview.

The gallery covers rooms and scenes, expanded controls, an unreachable light,
bridge setup and Bluetooth recovery, in both light and dark appearance.

- `liquid-glass/`: native Liquid Glass styling enabled.
- `fallback/`: Vesta’s glass styling disabled, showing its fallback layout and
  surfaces. These are **not screenshots of an older macOS installation**: native
  sliders, switches and other system controls still use the capture system’s style.

Captured on macOS 27 using the build from Xcode 26.3 (17C529), over the preview’s
fixed neutral backdrop. Images are JPEG screenshots from the window compositor,
without retouching. Liquid Glass requires macOS 26 or later; Vesta supports macOS
14 or later through runtime availability checks.

## Reproduce

```bash
swift build
.build/debug/Vesta --preview-snapshots
```

Use the **Snapshots** menu:

| Shortcut | Preview |
|---|---|
| Command–1 | Rooms and scenes |
| Command–2 | Expanded controls |
| Command–3 | Unreachable light |
| Command–4 | Bridge setup |
| Command–5 | Bluetooth recovery |
| Command–L / Command–D | Light / dark appearance |
| Command–G / Command–F | Liquid Glass / fallback styling |
| Command–Q | Quit preview and remove its backdrop |

Capture the “Vesta Screenshot Preview” window with a screen-capture tool that can
read the window compositor. The in-process renderer cannot reproduce Liquid Glass
without compositor capture. For compile-time fallback validation, build with
`VESTA_CLASSIC=1`; runtime fallback preview alone does not test an older SDK or OS.
