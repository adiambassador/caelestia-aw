<div align="center">

```
┏━╸┏━┓┏━╸╻  ┏━╸┏━┓╺┳╸╻┏━┓   ┏━┓╻ ╻
┃  ┣━┫┣╸ ┃  ┣╸ ┗━┓ ┃ ┃┣━┫╺━╸┣━┫┃╻┃
┗━╸╹ ╹┗━╸┗━╸┗━╸┗━┛ ╹ ╹╹ ╹   ╹ ╹┗┻┛
```

## **Animated wallpaper support for [Caelestia](https://github.com/caelestia-dots/caelestia)**

[![Shell Repo](https://img.shields.io/badge/shell-caelestia--shell--aw-9ccbfb?style=for-the-badge&logo=github)](https://github.com/AdiAmbassador/caelestia-shell-aw) [![CLI Repo](https://img.shields.io/badge/cli-caelestia--cli--aw-b9c8fb?style=for-the-badge&logo=github)](https://github.com/AdiAmbassador/caelestia-cli-aw) [![License](https://img.shields.io/badge/license-GPL--3.0-d3b4fb?style=for-the-badge)](LICENSE) [![Upstream](https://img.shields.io/badge/based%20on-caelestia--dots-f5c2e7?style=for-the-badge)](https://github.com/caelestia-dots)



https://github.com/user-attachments/assets/47f61a0c-7610-493e-8a5c-aeed5731cdc2

------



## What is this?

Caelestia-AW is a patch that adds **native animated/video wallpaper support** to Caelestia. It extends the wallpaper picker with a dedicated animated section, generates thumbnails for video files, and integrates fully with Caelestia's Material You dynamic color system.

This repo contains the  patcher and uninstall script. The actual code lives in two companion repos:

| Repo                                                         | What it changes                                              |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [caelestia-shell-aw](https://github.com/AdiAmbassador/caelestia-shell-aw) | QML: wallpaper picker UI, video rendering engine, thumbnail display, pausing logic. |
| [caelestia-cli-aw](https://github.com/AdiAmbassador/caelestia-cli-aw) | Python: video thumbnail generation, ffmpeg integration, Material You color extraction from video. |

------

### Warning:

This patch repository as well as the parent repository are known to not work properly in arch based distros like CachyOS, EndevourOS and Manjaro.
This intended only for Arch Linux. 



## Features

- **Video wallpapers:** `.mp4`, `.webm`, `.mkv`, `.gif` supported out of the box.
- **Separate animated picker:**  dedicated section in the launcher, no mixing with static wallpapers.
- **Video thumbnails:**  generated with the refresh button, cached by file hash, invalidated on file change.
- **Caelestia's Material You integration:**  dynamic color palette extracted from each video's representative frame.
- **Intelligent pausing:**  wallpaper pauses while on battery power or when a fullscreen app is active.
- **Real-time preview:**  scroll through the animated library and the wallpaper changes live.
- **Software decoding:**  consistent performance across all hardware, no driver dependency.
- **Hardware Decoding:** Added hardware decoders like VAAPI, VDPAU, VULKAN, CUDA and DRM. 

------

## Prerequisites

- Arch Linux 
- `yay` or `paru` AUR helper
- `fish` shell (required by the official Caelestia installer)
- `git`

------

## Installation

### Fresh install; Caelestia not yet installed

Install Caelestia CLI via AUR helper like yay or paru and install:

```bash
yay -S caelestia-cli
caelestia install
```



The next script clones my repo and installs the patches in place.

```bash
git clone https://github.com/AdiAmbassador/caelestia-aw.git ~/.local/share/caelestia-aw
~/.local/share/caelestia-aw/patch.sh 
```



### Existing Caelestia install; patch only

If you already have Caelestia installed and just want to add animated wallpaper support:

```bash
git clone https://github.com/AdiAmbassador/caelestia-aw.git ~/.local/share/caelestia-aw
~/.local/share/caelestia-aw/patch.sh 
```

------

The patch script will:

1. Copy the modified shell and CLI files into place.
2. Install the required dependencies (`qt6-multimedia`, `ffmpeg`, `python-pillow`)
3. Restart Caelestia automatically.

------



## Uninstall

cd over to the Caelestia-AW dotfiles clone, usually in:

```bash
cd ~/.local/share/caelestia-aw
```

Run:

```bash
bash uninstall.sh
```

Alternate method:

```bash
yay -S caelestia-cli caelestia-shell --overwrite '*'
```



## Usage

### Adding videos

Place your video files in:

```
~/Pictures/Wallpapers/Animated/
```

Supported formats: `.mp4`, `.webm`, `.mkv`, `.gif`

### Generating thumbnails

Open the launcher (`Super, >wallpaper ` by default), switch to the **Animated** tab, and press **Refresh**. Thumbnails will be generated for any new videos. For large collections this may take a few seconds; this is intentional to avoid a permanent background service.

Thumbnails are cached at `~/.cache/caelestia/videothumbs/` and only regenerate when a video file is modified.



------

</div>

#### Note on Hardware Decoders:

Hardware decoder support is an experimental feature added alongside Caelestia 2.1.0 compatibility patch. It is available in Caelestia Nexus settings.
Users need to manually install necessary drivers to use HW decode.
QtMultimedia will fallback to software decoding if currently selected decoder driver is unavailable.
Observed behaviour in my system:

- **VAAPI**: Ideal; minimal CPU usage; no lags while browsing wallpapers.
- **VDPAU**: Legacy support; Not much better than software decoding; no lags while browsing wallpapers.
- **CUDA**: minimal CPU usage; slight lag in each wallpaper change.
- **VULKAN**: minimal CPU usage; near 2s lag once. 
- **DRM**: Unable to test because of lack of possession of ARM device. 

------

<div align="center">

## Updating:

### Updating Caelestia-AW

To get the latest animated wallpaper patches:

```bash
cd caelestia-aw
```

Usually in:

```bash
cd ~/.local/share/caelestia-aw
```

And then:

```bash
git pull
bash patch.sh
```

This re-applies the patch on top of whatever version of Caelestia is currently supported.
Current v1.1.3 of Caelestia-AW patches Caelestia-2.2.0.

> **Note:** Updates to Caelestia-AW may be delayed from upstream Caelestia by a few or several days due to unforeseen compatibility issues. If you update vanilla Caelestia and something breaks, re-running `patch.sh` from the latest Caelestia-AW will resolve it.



### Updating vanilla Caelestia

If you update `caelestia-shell` or `caelestia-cli` via your AUR helper, the patch will be overwritten.

```bash
yay -S caelestia-shell caelestia-cli --overwrite '*'   # update upstream and overwrite
bash patch.sh                             # re-apply AW patch
```



------

## Known Limitations

~~**Software decoding only:**  hardware acceleration (VAAPI, CUDA, Vulkan) is intentionally disabled for consistent cross-hardware behavior. On lower-end machines, high-resolution 4K wallpapers may impact performance.~~

**Arch Linux only:**  the installer uses `pacman` and an AUR helper. Other distributions are not supported.

**Upstream updates:**  updating `caelestia-shell` or `caelestia-cli` via your AUR helper will overwrite the patch. Re-run `patch.sh` after any upstream update. 

------

## Relationship to Upstream

This project is based on [Caelestia](https://github.com/caelestia-dots) by [soramane](https://github.com/soramane) and contributors. All credit for the original shell architecture, widgets, configuration system, installer, and overall project belongs to them.

Caelestia-AW exists because animated wallpapers are currently outside the scope of the upstream project. The goal is to maintain these features as a focused fork while staying as compatible with upstream as possible, and potentially contributing the work upstream once it matures.

------

## Credits

- **[caelestia-dots](https://github.com/caelestia-dots)** : the original project this is built on

------

<div align="center"> <sub>Not affiliated with the official Caelestia project.</sub> </div>



## Upstream Documentation

This project is intended to be used alongside the official Caelestia project.

For complete installation instructions, configuration options, and documentation, see:

https://github.com/caelestia-dots/caelestia

</div>
