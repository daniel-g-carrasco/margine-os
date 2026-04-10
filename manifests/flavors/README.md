# Flavor overlays

This tree lets `Margine` support multiple manifest-resolution strategies
without splitting the repository into long-lived branches.

Rules:

- shared manifests stay in `../packages` and `../flatpaks`;
- a flavor only adds files here when it must replace part of the shared set;
- missing flavor files automatically fall back to the shared baseline;
- a flavor is smaller in scope than a product.

Current flavor overlays:

- `arch`
- `cachyos`
