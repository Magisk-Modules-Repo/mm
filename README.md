# Magisk Manager for Recovery Mode
## VR25 @ xda-developers


### Disclaimer
- This software is provided as is, in the hope that it will be useful, but without any warranty. Always read the reference prior to installing/updating it. While no cats have been harmed in any way, shape or form, I assume no responsibility under anything that might go wrong due to the use/misuse of it.
- A copy of the GNU General Public License, version 3 or newer is included with every version. Please, read it prior to using, modifying and/or sharing any part of this work.
- To avoid fraud, DO NOT mirror any link associated with the project.


### Description
- Manage your Magisk image, data, modules & settings from recovery mode -- run "/data/media/mm" on terminal.


### Features
- Enable/disable modules
- Change Magisk settings (using vi text editor)
- Automatically fix magisk.img (e2fsck -fy)
- List installed modules
- Make magisk.img survive standard TWRP factory resets
- Resize magisk.img
- Toggle auto_mount
- Uninstall modules


### Installation
- Flash in Magisk Manager app or recovery as a regular Magisk module.


### Usage
- First time (right after installing/updating) -- run "mm" (on recovery terminal).
- Next times (while in recovery) -- no need to re-flash the zip; simply run "/data/media/mm" on terminal.
- Follow the instructions/wizard; everything is interactive.


### Online Support
- [Git Repository](https://github.com/Magisk-Modules-Repo/Magisk-Manager-for-Recovery-Mode)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-tool-magisk-manager-recovery-mode-t3693165)


### Recent Changes

**2018.7.24 (201807240)**
- Fixed modPath detection issue (Magisk V16.6).
- Updated documentation

**2018.3.6 (201803060)**
- Reverted image mount point to /magisk for easier access (mm must be running or closed with CTRL+C)
- Misc optimizations

**2018.1.31 (201801310)**
- Ability to change Magisk settings (using vi text editor)
- Improved compatibility with all major Magisk versions currently in use
- Major optimizations
- Updated reference

**2017.11.25-1 (201711251)**
- Fixed "non-existent tmpd" error
