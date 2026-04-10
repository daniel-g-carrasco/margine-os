# CachyOS flavor

`cachyos` starts from the shared `Margine` baseline and can selectively replace
manifests from:

- `manifests/packages`
- `manifests/flatpaks`

Place override files under:

- `packages/<layer>.txt`
- `flatpaks/apps.txt`

Only add files when the CachyOS flavor truly needs to diverge from the shared
baseline.
