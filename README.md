# Magisk Manager for Recovery Mode
## (c) 2017-2018, VR25 @ xda-developers
### License: GPL v3+



#### DISCLAIMER

- This software is provided as is, in the hope that it will be useful, but without any warranty. Always read the reference prior to installing/updating. While no cats have been harmed, I assume no responsibility under anything that might go wrong due to the use/misuse of it.
- A copy of the GNU General Public License, version 3 or newer ships with every build. Please, read it prior to using, modifying and/or sharing any part of this work.
- To prevent fraud, DO NOT mirror any link associated with the project.



#### DESCRIPTION

- Manage your Magisk image, data, modules & settings from recovery mode -- run "/data/media/mm" on terminal.



### FEATURES

- Enable/disable modules
- Change Magisk settings (using vi text editor)
- Automatically fix magisk.img (e2fsck -fy)
- List installed modules
- Make magisk.img survive standard TWRP factory resets
- Resize magisk.img
- Toggle auto_mount
- Uninstall modules



### INSTALATION

- Flash from Magisk Manager or TWRP as a regular Magisk module.



### USAGE

- First time (right after installing/updating) -- run "mm" (on recovery terminal).
- Next times (while in recovery) -- no need to re-flash the zip; simply run "/data/media/mm" on terminal.
- Follow the instructions/wizard. Everything is interactive.



### ONLNE SUPPORT

- [Git Repository](https://github.com/Magisk-Modules-Repo/Magisk-Manager-for-Recovery-Mode)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-tool-magisk-manager-recovery-mode-t3693165)



### RECENT CHANGES

**2018.8.1 (201808010)**
- General optimizations
- New & simplified installer
- Striped down (removed unnecessary code & files)
- Updated documentation

**2018.7.24 (201807240)**
- Fixed modPath detection issue (Magisk V16.6).
- Updated documentation

**2018.3.6 (201803060)**
- Reverted image mount point to /magisk for easier access (mm must be running or closed with CTRL+C)
- Misc optimizations
