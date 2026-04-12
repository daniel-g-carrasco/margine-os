# Because on Hyprland the composer's ICC remains optional

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
4. Leave the ICC of `Hyprland` as the next, conscious step.

## What this means in practice

Per ora:

- `darktable` is the main point where the display profile really matters;
- the browser does not receive aggressive ICC tweaks;
- `Hyprland` does not enforce a global ICC by default.

Then, when the flow is validated well on the real monitor, we can add
the `icc` line in the monitor configuration of `Hyprland`.

## Right mental rule

If you are still building the system:

- first make stack and assets reliable;
- then choose where to apply the color;
- only at the end do you move the most global lever.