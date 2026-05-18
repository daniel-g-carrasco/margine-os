# Because on Hyprland the composer's ICC remains optional

Update 2026-05-16: this note records the original conservative rule. It is now
superseded for one explicit case: Hyprland 0.55 on Daniel's Framework 13 BOE
panel can use the validated `FW13_D65_GNOME_COLORS.icc` profile through a
descriptor-scoped monitor rule. The general rule still stands for unknown or
unvalidated displays: keep ICC assets and `colord`, then enable compositor ICC
only after validating the exact monitor/profile pair.

The point is not whether `Hyprland` supports ICCs or not.

He supports them.

The real point is another:

- where you want to apply the color transformation;
- how easily you want to be able to understand a problem;
- how confident you are in the profile you are using.

## The three levels

In our case there are three distinct levels:

- the ICC profile as an asset;
- `colord` as system registry;
- the `Hyprland` composer as a possible global application point.

These three levels should not be confused.

## Why don't we activate it right away

An ICC loaded into the composer changes the behavior of the entire session.

This means that if something doesn't add up:

- you don't immediately understand if the problem is in the profile;
- you don't immediately understand if the problem is in the application;
- you don't immediately understand if the problem is in the composer.

For a didactic and stable `v1`, this is a terrible start.

## The Margin strategy

The chosen strategy is this:

1. preserve good ICC profiles;
2. install and hold `colord`;
3. use applications that really support color management first;
4. enable the ICC of `Hyprland` only after the exact monitor/profile pair is
   validated.

## What this means in practice

Baseline attuale:

- `darktable` is the main point where the display profile really matters;
- the browser does not receive aggressive ICC tweaks;
- `Hyprland` applies compositor ICC only to `desc:BOE NE135A1M-NY1` with the
  `FW13 D65` GNOME Colors / `colord-session` profile.

The former `FW13_140cd_D65_2.2_S.icc` DisplayCAL/Argyll profile is preserved as
an asset, but it is not the default Hyprland profile.

## Right mental rule

If you are still building the system:

- first make stack and assets reliable;
- then choose where to apply the color;
- only at the end do you move the most global lever.
