# Because VRR, refresh rate and power profile must be separated

There are three different levers, and mixing them leads to confusing decisions.

## 1. Power profile

The power profile decides how the system behaves on the CPU, firmware and
platform profile.

In our case the right engine is:

- `power-profiles-daemon`

He handles things like:

- `balanced`
- `power-saver`
- `performance`

This level does not automatically tell you how many Hz the panel should be at.

## 2. Panel power savings / ABM

On the AMD Framework 13, `power-profiles-daemon` exposes a separate action:

- `amdgpu_panel_power`

The important fact is that the daemon himself describes it as something that can
"affect color quality". For a photographic system, this is enough to justify
a conservative baseline: keep that action disabled.

This is not the same as choosing `balanced` or `power-saver`.

## 3. Panel refresh rate

The refresh rate is yet another lever.

Dire:

- `60Hz su batteria`
- `120Hz su alimentazione`

it doesn't mean "change power profile". It means changing the monitor mode.

This lever is useful because it produces a predictable effect on consumption
panel, while the energy profile alone does not guarantee that result.

## 4. VRR

`VRR` significa Variable Refresh Rate / Adaptive Sync.

It is useful for fluidity and tearing in compatible scenarios, but does not replace the
explicit change from `120Hz` to `60Hz`.

So:

- `VRR` is not the main energy saving;
- the explicit change `60/120Hz` remains the concrete lever for the laptop;
- the power profile remains yet another level.

## Practical Margin Decision

This is why `Margine` separates the three layers:

- `power-profiles-daemon` as energy profile engine;
- `amdgpu_panel_power=false` as a conservative baseline for the AMD panel;
- separate user service to change `60/120Hz`;
- `VRR` only as optional composer support.