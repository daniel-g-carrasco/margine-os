# DaVinci Resolve on Linux: drivers and runtime requirements

## The short answer

Yes, Linux has OpenGL drivers.

But for `DaVinci Resolve`, OpenGL is not the real difficulty.

The real difficulty on Linux is the whole runtime stack together:

- graphics driver
- GPU compute backend
- multimedia compatibility libraries
- distro compatibility assumptions

If you only ask:

> "Do I need OpenGL drivers?"

the answer is:

> "Yes, but that is far from sufficient."

## What "OpenGL drivers on Linux" actually means

On Linux, OpenGL support is normally provided by the GPU driver stack.

### AMD and Intel

In most common open-source setups, OpenGL is provided by `Mesa`.

### NVIDIA

In NVIDIA setups, OpenGL usually comes from the proprietary NVIDIA driver
stack.

So the concept of "OpenGL drivers for Linux" is normal and real. This is not a
special DaVinci Resolve feature. It is standard Linux graphics infrastructure.

## Why OpenGL is not the main issue for Resolve

For DaVinci Resolve on Linux, the bigger issue is compute support.

In practical terms, that usually means:

- OpenCL on AMD
- CUDA on NVIDIA

This is the part that tends to break expectations on Arch-like systems.

You can have:

- working desktop graphics
- working Wayland or X11
- working OpenGL

and still not have a usable Resolve installation if the compute runtime is
missing or incompatible.

## Official support position

Blackmagic Design's current public Linux support target remains:

- `Rocky Linux 8.6`

This matters because Arch and CachyOS are not the official reference platform.

So on CachyOS or Margine-CachyOS, Resolve is best treated as:

- technically possible
- operationally fragile
- not officially guaranteed

## What the Arch packaging metadata shows

The current `davinci-resolve` AUR package metadata declares these runtime
dependencies:

- `glu`
- `gtk2`
- `libpng12`
- `fuse2`
- `opencl-driver`
- `qt5-x11extras`
- `qt5-svg`
- `qt5-webengine`
- `qt5-websockets`
- `qt5-quickcontrols2`
- `qt5-multimedia`
- `libxcrypt-compat`
- `xmlsec`
- `java-runtime`
- `ffmpeg4.4`
- `gst-plugins-bad-libs`
- `python-numpy`
- `tbb`
- `apr-util`
- `luajit`
- `libc++`
- `libc++abi`

This tells you something important immediately:

Resolve on Arch-like systems is not a single-package story.

It is a compatibility stack.

## The three layers Resolve really needs

## 1. Graphics layer

You still need a sane graphics stack:

- a functioning GPU driver
- working OpenGL userspace
- working display acceleration

Without that, the application is already on unstable ground.

## 2. Compute layer

This is the critical layer.

Resolve expects a real compute backend.

In practical terms:

- AMD users usually need a valid OpenCL runtime
- NVIDIA users usually need the proprietary NVIDIA stack and CUDA/OpenCL
  support that Resolve actually works with

This is why desktop acceleration and Resolve readiness are not the same thing.

## 3. Compatibility/runtime layer

Resolve on Arch-like systems often needs:

- older or compatibility multimedia libraries
- Qt5 compatibility pieces
- legacy-ish runtime dependencies
- packaging workarounds

That is why many Linux users say "it launches" and "it is production-ready" as
two completely different states.

## What this means for AMD, NVIDIA, and Intel

## AMD

AMD is attractive on Linux because the desktop experience is often excellent.

However, for Resolve the question is not:

- "Does the desktop run well?"

The question is:

- "Is there a working OpenCL path that Resolve accepts and uses reliably?"

So AMD can be good, but only if the compute side is validated explicitly.

## NVIDIA

NVIDIA is often the more predictable Resolve choice because proprietary driver
support and compute support are usually closer to what commercial media
applications expect.

The tradeoff is obvious:

- potentially less elegant Linux integration
- often better compatibility with commercial GPU workloads

## Intel

Intel can be fine for normal desktop use, but is not where I would place
primary expectations for a serious Resolve workstation path unless validated
very carefully for the exact workload.

## What a Margine-CachyOS Resolve layer would actually need

If Margine ever wants a real `davinci-resolve` layer, it should not be modeled
as "install one package".

It should be modeled as:

## A. GPU-vendor-aware logic

At minimum:

- detect AMD vs NVIDIA vs Intel
- choose the correct compute-runtime strategy
- fail early if the system is not in a supportable state

## B. Explicit runtime dependency layer

The layer should own:

- required compatibility packages
- compute runtime packages
- media/runtime compatibility packages
- any required environment or launch wrappers

## C. Validation, not hope

The layer should validate:

- GPU driver visibility
- OpenGL availability
- compute backend availability
- codec/runtime dependencies
- actual application startup

Without those checks, "support" would only mean "the package installed".

That is not enough.

## D. Documentation of support boundaries

The docs should explicitly say:

- Blackmagic supports Rocky Linux 8.6
- CachyOS/Arch-based use is community-driven
- behavior may differ by GPU vendor
- desktop acceleration does not prove Resolve compute readiness

## Are OpenGL drivers specifically required?

Yes, in the ordinary sense that Resolve needs a working graphics driver stack.

But if you ask:

> "Is OpenGL the key thing I need to solve?"

the answer is:

> "No. The compute stack and compatibility stack are the real problem."

## What I would recommend for Margine

For now, the sensible position is:

- do not advertise DaVinci Resolve support as a default baseline feature
- treat it as a future specialized layer
- design it as vendor-aware and validation-heavy

If you want to pursue it later, the rollout should be:

1. define supported GPU vendors first
2. define the runtime dependency layer
3. define validation commands
4. test on real hardware
5. only then document it as a supported Margine capability

## The real lesson

Commercial media software on Linux is not the same thing as:

- a good desktop
- a working compositor
- working VA-API
- working Vulkan

Those help, but they are not the same as a validated Resolve runtime.

For Resolve, you need to think in layers:

- desktop graphics
- compute backend
- compatibility libraries
- vendor-specific reality

That is the correct mental model.

## Sources and references

- Blackmagic Design DaVinci Resolve tech specs:
  `https://www.blackmagicdesign.com/products/davinciresolve/techspecs`
- AUR `davinci-resolve` metadata:
  `https://aur.archlinux.org/packages/davinci-resolve`
- AUR `davinci-resolve-studio` metadata:
  `https://aur.archlinux.org/packages/davinci-resolve-studio`
