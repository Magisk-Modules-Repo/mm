# Magisk Manager for Recovery Mode
# VR25 @ XDA Developers


**Description**
- Manage your Magisk image, data, modules & settings in recovery mode.


**Disclaimer**
- Don't blame me if you end up triggering a nuclear disaster with this module! You do everything at your own risk.


**Features**
- Enable/disable modules
- Change Magisk settings (WIP)
- Fix magisk.img (e2fsck -fy)
- List installed modules
- Make magisk.img survive factory resets
- Resize magisk.img
- Toggle auto_mount
- Uninstall modules


**Installation**
- Flash from Magisk Manager app or recovery as if it were a regular Magisk module.


**Usage**
- First time (right after installing/updating) -- run "mm" (on recovery terminal).
- Next times (while in recovery) -- no need to re-flash the zip; simply run "/data/media/mm" on terminal.
- Follow the instructions/wizard; everything is interactive.


**Notes/tips**
- The option to run `e2fsck -fy /data/magisk.img` is meant for fixing magisk.img corruption/errors caused by a module or abrupt system shutdown. This is particularly useful when magisk.img is inaccessible in recovery mode (i.e., cannot be mounted due to curruption).


**Online Support**
- [Git Repository](https://github.com/Magisk-Modules-Repo/Magisk-Manager-for-Recovery-Mode)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-tool-magisk-manager-recovery-mode-t3693165)