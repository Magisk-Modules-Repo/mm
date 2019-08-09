# Magisk Manager for Recovery Mode (mm)



## LEGAL

Copyright (C) 2017-2019, VR25 @ xda-developers

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.



## DISCLAIMER

Always read/reread this reference prior to installing/upgrading this software.

While no cats have been harmed, the author assumes no responsibility for anything that might break due to the use/misuse of it.

To prevent fraud, do NOT mirror any link associated with this project; do NOT share builds (zips)! Share official links instead.



## DESCRIPTION

- Manage your Magisk modules from recovery (e.g., TWRP) -- run "sh /sdcard/mm" on recovery terminal.

Features list
- Automatically fix magisk.img (e2fsck -fy)
- List installed modules
- Toggle
  - Core only mode
  - Magic mount
  - Disable
  - Remove



## PREREQUISITE

- Magisk 17-19



## SETUP

### Install
Flash live (e.g., from Magisk Manager) or from custom recovery (e.g., TWRP).

### Manually Install
Copy `mm` either from the zip or [github](https://github.com/Magisk-Modules-Repo/mm/raw/master/mm) to `/sdcard` or `/data/media/`.

### Uninstall
Use Magisk Manager app or mm itself (supports `uninstall.sh`, too).


## USAGE

- run `sh /sdcard/mm` on recovery terminal.
- Follow the instructions/wizard. Everything is interactive.
- Pro tip: lazy people can try running `*/mm` instead of `sh /sdcard/mm` or running `mm` right after installing/updating.

## LINKS

- [Donate](https://paypal.me/vr25xda/)
- [Facebook page](https://facebook.com/VR25-at-xda-developers-258150974794782/)
- [Git repository](https://github.com/Magisk-Modules-Repo/mm)
- [Telegram channel](https://t.me/vr25_xda/)
- [Telegram profile](https://t.me/vr25xda/)
- [XDA thread](https://forum.xda-developers.com/apps/magisk/module-tool-magisk-manager-recovery-mode-t3693165)



## LATEST CHANGES

**2019.4.4 (201904040)**
- Complete redesign
- Magisk 17-19 support (including `uninstall.sh`)
- Toggle core only mode
- Updated information (copyright, documentation, and module description)

**2018.8.1 (201808010)**
- General optimizations
- New & simplified installer
- Striped down (removed unnecessary code & files)
- Updated documentation

**2018.7.24 (201807240)**
- Fixed modPath detection issue (Magisk 16.6).
- Updated documentation
