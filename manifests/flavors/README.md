# Flavor overlays

This tree lets `Margine` support multiple distro flavors without splitting the
whole repository into long-lived branches.

Rules:

- shared manifests stay in `../packages` and `../flatpaks`;
- a flavor only adds files here when it must replace part of the shared set;
- missing flavor files automatically fall back to the shared baseline.

Current flavors:

- `arch`
- `cachyos`
