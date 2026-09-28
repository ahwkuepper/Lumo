# Changelog

Notable changes per release. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versions follow [semantic versioning](https://semver.org).

Vesta makes no network call to tell you a new version exists — see
[Updates](README.md#updates) for how to find out.

## [0.2.0] — 2026-09-28

### Changed
- Refined the existing menu-bar design with native Liquid Glass surfaces on macOS
  26+, clearer grouping and a polished fallback for macOS 14 and later.
- Replaced transparent custom slider handles with native macOS sliders, retaining
  colour tracks, keyboard control and accessibility value descriptions.
- Refreshed the README with light and dark screenshots of both appearances,
  including setup, expanded controls and connection recovery.

### Added
- An interactive screenshot preview backed entirely by simulated lights.
- An installation script that updates the everyday copy in `/Applications` while
  preserving its signing identity.

### Fixed
- Prevented multiple GUI instances, including when another copy is launched.
- Moved development and release app staging into hidden `.build` storage and
  migrated the old staging location so it stops creating duplicate app-search
  entries.
- Recheck Bluetooth availability when opening the popover, recover a stale manager
  after permission changes, and offer **Retry Connection** without quitting.
- Cancelled obsolete transport work and ignored stale callbacks after switching
  connection modes or restarting a connection.

## [0.1.0] — 2026-08-31

First release. A menu-bar Hue controller that talks to the bridge on your network
and to nothing else.

### Added
- Universal binary (Apple silicon and Intel) for released builds.
- `tools/verify-release.sh`, which rebuilds a release from its tag and compares the
  unsigned binary with the published hash.
- `tools/remove-signing-identity.sh`, which removes the trusted code-signing root
  that `make-signing-identity.sh` installs. Nothing removed it before.
- In-app pairing. Discovery reads the bridge id from the mDNS TXT record and derives
  the `.local` name, with manual address entry for networks that block mDNS.
- An About panel carrying the version, the licence and the non-affiliation notice.
- Signed, notarised disk images, and CI attestation of the unsigned binary's hash
  through GitHub's transparency log.

### Changed
- Licence is now Apache-2.0. Section 6 grants no trademark rights and section 5
  makes inbound-equals-outbound explicit; MIT does neither.
- Release builds pin the toolchain and refuse a beta Xcode or an ad-hoc signature.

### Fixed
- The README claimed diagnostics carry the bridge address. They carry the kind of
  address and never the value — the code was right and the prose was wrong.
- `CONTRIBUTING.md` required a sign-off on every commit, which no commit had. It now
  applies to pull requests, where it can actually be met.
