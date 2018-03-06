#!/sbin/sh
# Magisk Manager for Recovery Mode (mm)
# VR25 @ xda-developers

# Detect whether in boot mode
ps | grep zygote | grep -v grep >/dev/null && BOOTMODE=true || BOOTMODE=false
$BOOTMODE || ps -A 2>/dev/null | grep zygote | grep -v grep >/dev/null && BOOTMODE=true
$BOOTMODE || id | grep -q 'uid=0' || BOOTMODE=true

# Exit script if running in boot mode
if $BOOTMODE; then
	echo -e "\nI saw what you did there... :)"
	echo "- Bad idea!"
	echo -e "- This is meant to be used in recovery mode only.\n"
	exit 1
fi

# Default permissions
umask 022

##########################################################################################
# Functions
##########################################################################################

is_mounted() { mountpoint -q "$1"; }

mount_image() {
  e2fsck -fy $IMG &>/dev/null
  if [ ! -d "$2" ]; then
    mount -o remount,rw /
    mkdir -p "$2"
  fi
  if (! is_mounted $2); then
    LOOPDEVICE=
    for LOOP in 0 1 2 3 4 5 6 7; do
      if (! is_mounted $2); then
        LOOPDEVICE=/dev/block/loop$LOOP
        [ -f "$LOOPDEVICE" ] || mknod $LOOPDEVICE b 7 $LOOP 2>/dev/null
        losetup $LOOPDEVICE $1
        if [ "$?" -eq "0" ]; then
          mount -t ext4 -o loop $LOOPDEVICE $2
          is_mounted $2 || /system/bin/toolbox mount -t ext4 -o loop $LOOPDEVICE $2
          is_mounted $2 || /system/bin/toybox mount -t ext4 -o loop $LOOPDEVICE $2
        fi
        is_mounted $2 && break
      fi
    done
  fi
  if ! is_mounted $MOUNTPATH; then
    echo -e "\n(!) $IMG mount failed... abort\n"
    exit 1
  fi
}

set_perm() {
  chown $2:$3 "$1" || exit 1
  chmod $4 "$1" || exit 1
  [ -z "$5" ] && chcon 'u:object_r:system_file:s0' "$1" || chcon $5 "$1"
}

set_perm_recursive() {
  find "$1" -type d 2>/dev/null | while read dir; do
	set_perm "$dir" $2 $3 $4 $6
  done
  find "$1" -type f -o -type l 2>/dev/null | while read file; do
	set_perm "$file" $2 $3 $5 $6
  done
}

Actions() {
	echo
	cat <<EOD
e) Enable/disable modules
l) List installed modules
m) Make magisk.img survive f. resets
r) Resize magisk.img
s) Change Magisk settings (using vi text editor)
t) Toggle auto_mount
u) Uninstall modules
---
x. Exit
EOD
	read Input
	echo
}

exit_or_not() {
	echo -e "\n(i) Would you like to do anything else? (Y/n)"
	read Ans
	echo $Ans | grep -iq n && echo && exxit || Opts
}

mod_ls() { ls -1 $MOUNTPATH | grep -v 'lost+found'; }


Toggle() {
	echo "<Toggle $1>" 
	: > $tmpf
	: > $tmpf2
	Input=0
	
	for mod in $(mod_ls); do
		if $auto_mount; then
			[ -f "$mod/$2" ] && echo "$mod (ON)" >> $tmpf \
				|| echo "$mod (OFF)" >> $tmpf
		else
			[ -f "$mod/$2" ] && echo "$mod (OFF)" >> $tmpf \
				|| echo "$mod (ON)" >> $tmpf
		fi
	done
	
	echo
	cat $tmpf
	echo
	
	echo "(i) Input a matching WORD/string at once"
	echo "- Press ENTER when done; CTRL+C to exit"

	until [ -z "$Input" ]; do
		read Input
		if [ "$Input" ]; then
			grep "$Input" $tmpf | grep -q '(ON)' && \
				echo "$3 $(grep "$Input" $tmpf | grep '(ON)')/$2" >> $tmpf2
			grep "$Input" $tmpf | grep -q '(OFF)' && \
				echo "$4 $(grep "$Input" $tmpf | grep '(OFF)')/$2" >> $tmpf2
		fi
	done
	
	cat $tmpf2 | sed 's/ (ON)//' | sed 's/ (OFF)//' > $tmpf
	
	if grep -Eq '[0-9]|[a-z]|[A-Z]' $tmpf; then
		. $tmpf
		echo "Result(s):"
		
		grep -q '(ON)' $tmpf2 && cat $tmpf2 \
			| sed 's/(ON)/(ON) --> (OFF)/' \
			| sed "s/$3 //" | sed "s/$4 //" | sed "s/\/$2//"
		grep -q '(OFF)' $tmpf2 && cat $tmpf2 \
			| sed 's/(OFF)/(OFF) --> (ON)/' \
			| sed "s/$3 //" | sed "s/$4 //" | sed "s/\/$2//"
	
	else
		echo "(i) Operation aborted: null/invalid input"
	fi
}


auto_mnt() { auto_mount=true; Toggle auto_mount auto_mount rm touch; }

enable_disable_mods() { auto_mount=false; Toggle "Module ON/OFF" disable touch rm; }

exxit() {
	cd $TmpDir
	umount $MOUNTPATH
	losetup -d $LOOPDEVICE
	rmdir $MOUNTPATH
	[ "$1" != "1" ] && exec echo -e "Goodbye.\n" || exit 1
}

list_mods() {
	echo -e "<Installed Modules>\n"
	mod_ls
}


Opts() {
	echo -e "\n(i) Pick an option..."
	Actions

	case "$Input" in
		e ) enable_disable_mods;;
		l ) list_mods;;
		m ) immortal_m;;
		r ) resize_img;;
		s ) m_settings;;
		t ) auto_mnt;;
		u ) rm_mods;;
		x ) exxit;;
		* ) Opts;;
	esac
	
	exit_or_not
}


resize_img() {
	echo -e "<Resize magisk.img>\n"
	cd $TmpDir
	df -h $MOUNTPATH
	umount $MOUNTPATH
	losetup -d $LOOPDEVICE
	echo -e "\n(i) Input the desired size in MB"
	echo "- Or nothing to cancel"
	echo "- Press CTRL+C to exit"
	read Input
	if [ -n "$Input" ]; then
		echo
		resize2fs $IMG ${Input}M
	else
		echo "(i) Operation aborted: null/invalid input"
	fi
	mount_image $IMG $MOUNTPATH
	cd $MOUNTPATH
}


rm_mods() { 
	: > $tmpf
	: > $tmpf2
	Input=0
	list_mods
	echo
	echo "Input a matching WORD/string at once"
	echo "- Press ENTER when done; CTRL+C to exit"

	until [ -z "$Input" ]; do
		read Input
		[ "$Input" ] && mod_ls | grep "$Input" \
			| sed 's/^/rm -rf /' >> $tmpf \
			&& mod_ls | grep "$Input" >> $tmpf2
	done

	if grep -Eq '[0-9]|[a-z]|[A-Z]' $tmpf; then
		. $tmpf
		echo "Removed Module(s):"
		cat $tmpf2
	else
		echo "(i) Operation aborted: null/invalid input"
	fi
}


immortal_m() {
	F2FS_workaround=false
	if ls /cache | grep -i magisk | grep -iq img; then
		echo "(i) A Magisk image file has been found in /cache"
		echo "- Are you using the F2FS bug cache workaround? (y/N)"
		read F2FS_workaround
		echo
		case $F2FS_workaround in
			[Yy]* ) F2FS_workaround=true;;
			* ) F2FS_workaround=false;;
		esac
		
		$F2FS_workaround && echo "(!) This option is not for you then"
	fi
	
	if ! $F2FS_workaround; then
		if [ ! -f /data/media/magisk.img ] && [ -f "$IMG" ] && [ ! -h "$IMG" ]; then
			Err() { echo "$1"; exit_or_not; }
			echo "(i) Moving $IMG to /data/media"
			mv $IMG /data/media \
				&& echo "-> ln -s /data/media/magisk.img $IMG" \
				&& ln -s /data/media/magisk.img $IMG \
				&& echo -e "- All set.\n" \
				&& echo "(i) Run this again after a factory reset to recreate the symlink." \
				|| Err "- (!) $IMG couldn't be moved"
			
		else
			if [ ! -e "$IMG" ]; then
				echo "(i) Fresh ROM, uh?"
				echo "-> ln -s /data/media/magisk.img $IMG"
				ln -s /data/media/magisk.img $IMG \
				&& echo "- Symlink recreated successfully" \
				&& echo "- You're all set" \
				|| echo -e "\n(!) Symlink creation failed"
			else
				echo -e "(!) $IMG exists -- symlink cannot be created"
			fi
		fi
	fi
}


m_settings() {
	echo "(!) Warning: potentially dangerous section"
	echo "- For advanced users only"
	echo "- Proceed? (y/N)"
	read Ans

	if echo "$Ans" | grep -i y; then
		cat <<EOD

Some Basic vi Usage

i --> enable typing mode

esc key --> return to comand mode
ZZ --> save changes & exit
:q! ENTER --> discard changes & exit
/STRING --> put cursor on the first character of STRING


Note that I'm no vi expert by any means, but the above should suffice.

Hit ENTER to continue...
EOD
		read
		vi /data/data/com.topjohnwu.magisk/shared_prefs/com.topjohnwu.magisk_preferences.xml
	fi
}
##########################################################################################
# Environment
##########################################################################################

TmpDir=/dev/mm_tmp
tmpf=$TmpDir/tmpf
tmpf2=$TmpDir/tmpf2
MOUNTPATH=/magisk

mount /data 2>/dev/null
mount /cache 2>/dev/null

[ -d /data/adb/magisk ] && IMG=/data/adb/magisk.img || IMG=/data/magisk.img

if [ ! -d /data/adb/magisk ] && [ ! -d /data/magisk ]; then
	echo -e "\n(!) No Magisk installation found or installed version is not supported\n"
	exit 1
fi

mkdir -p $TmpDir 2>/dev/null
mount_image $IMG $MOUNTPATH
cd $MOUNTPATH

echo -e "\nMagisk Manager for Recovery Mode (mm)"
echo "- VR25 @ xda-developers"
echo -e "- Powered by Magisk (@topjohnwu)\n"
Opts
