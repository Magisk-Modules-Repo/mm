# Magisk Manager for Recovery Mode
# VR25 @ XDA Developers


**Description**
- Manage your Magisk image & modules from recovery.


**Disclaimer**
- Use at your own risk.


**Features**
- Enable/disable modules
- Fix magisk.img (e2fsck -fy)
- List installed modules
- Resize magisk.img
- Toggle auto_mount
- Uninstall modules


**Installation**
- Flash from Magisk Manager app or recovery as a regular Magisk module.


**Usage**
- First time, right after flashing (recovery mode) -- simply run `mm` on terminal.
- Else (after installing & rebooting) -- run `. /data/magisk/mm`.
- Follow the instructions/wizard; everything is interactive.


**Notes/Tips**
- The option to run `e2fsck -fy /data/magisk.img` is great for fixing bootlops due to magisk.img corruption/errors caused by a module or abrupt system shutdown.


**Online Support**
- [Git Repo](https://github.com/VR-25/Magisk-Manager-for-Recovery-Mode)
- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-tool-magisk-manager-recovery-mode-t3693165)
