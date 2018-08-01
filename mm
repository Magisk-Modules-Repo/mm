#!/sbin/sh
# (c) 2017-2018, VR25 @ xda-developers
# License: GPL v3+



# detect whether in boot mode
ps | grep zygote | grep -v grep >/dev/null && BOOTMODE=true || BOOTMODE=false
$BOOTMODE || ps -A 2>/dev/null | grep zygote | grep -v grep >/dev/null && BOOTMODE=true
$BOOTMODE || id | grep -q 'uid=0' || BOOTMODE=true

# exit if running in boot mode
if $BOOTMODE; then
	echo -e "\nI saw what you did there... :)"
	echo "- Bad idea!"
	echo -e "- This is meant to be used in recovery mode only.\n"
	exit 1
fi

# Default permissions
umask 022



is_mounted() { mountpoint -q "$1"; }

mount_image() {
  e2fsck -fy $IMG &>/dev/null
  if [ ! -d "$2" ]; then
    mount -o remount,rw /
    mkdir -p "$2"
  fi
  if (! is_mounted $2); then
    loopDevice=
    for LOOP in 0 1 2 3 4 5 6 7; do
      if (! is_mounted $2); then
        loopDevice=/dev/block/loop$LOOP
        [ -f "$loopDevice" ] || mknod $loopDevice b 7 $LOOP 2>/dev/null
        losetup $loopDevice $1
        if [ "$?" -eq "0" ]; then
          mount -t ext4 -o loop $loopDevice $2
          is_mounted $2 || /system/bin/toolbox mount -t ext4 -o loop $loopDevice $2
          is_mounted $2 || /system/bin/toybox mount -t ext4 -o loop $loopDevice $2
        fi
        is_mounted $2 && break
      fi
    done
  fi
  if ! is_mounted $mountPath; then
    echo -e "\n(!) $IMG mount failed... abort\n"
    exit 1
  fi
}



actions() {
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
	echo $Ans | grep -iq n && echo && exxit || opts
}

ls_mount_path() { ls -1 $mountPath | grep -v 'lost+found'; }


toggle() {
	echo "<Toggle $1>" 
	: > $tmpf
	: > $tmpf2
	Input=0
	
	for mod in $(ls_mount_path); do
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
	echo "- Press ENTER twice when done; CTRL+C to exit"

	until [ -z "$Input" ]; do
		read Input
		if [ -n "$Input" ]; then
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


auto_mnt() { auto_mount=true; toggle auto_mount auto_mount rm touch; }

enable_disable_mods() { auto_mount=false; toggle "Module ON/OFF" disable touch rm; }

exxit() {
	cd $tmpDir
	umount $mountPath
	losetup -d $loopDevice
	rmdir $mountPath
	[ "$1" != "1" ] && exec echo -e "Goodbye.\n" || exit 1
}

list_mods() {
	echo -e "<Installed Modules>\n"
	ls_mount_path
}


opts() {
	echo -e "\n(i) Pick an option..."
	actions

	case "$Input" in
		e ) enable_disable_mods;;
		l ) list_mods;;
		m ) immortal_m;;
		r ) resize_img;;
		s ) m_settings;;
		t ) auto_mnt;;
		u ) rm_mods;;
		x ) exxit;;
		* ) opts;;
	esac
	
	exit_or_not
}


resize_img() {
	echo -e "<Resize magisk.img>\n"
	cd $tmpDir
	df -h $mountPath
	umount $mountPath
	losetup -d $loopDevice
	echo -e "\n(i) Input the desired size in MB"
	echo "- Or nothing to cancel"
	read Input
	[ -n "$Input" ] && echo -e "\n$(resize2fs $IMG ${Input}M)" \
    || echo -e "\n(!) Operation aborted: null/invalid input"
	mount_image $IMG $mountPath
	cd $mountPath
}


rm_mods() { 
	: > $tmpf
	: > $tmpf2
	Input=0
	list_mods
	echo -e "\n(i) Input a matching WORD/string at once"
	echo "- Press ENTER twice when done, CTRL+C to exit"

	until [ -z "$Input" ]; do
		read Input
		[ -n "$Input" ] && ls_mount_path | grep "$Input" \
			| sed 's/^/rm -rf /' >> $tmpf \
			&& ls_mount_path | grep "$Input" >> $tmpf2
	done

	if grep -Eq '[0-9]|[a-z]|[A-Z]' $tmpf; then
		. $tmpf
		echo "Removed Module(s):"
		cat $tmpf2
	else
		echo "(!) Operation aborted: null/invalid input"
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

i --> enable insertion/typing mode

esc key --> return to comand mode
ZZ --> save changes & exit
:q! ENTER --> discard changes & exit
/STRING --> go to STRING


Note that I'm no vi expert by any meAns, but the above should suffice.

Hit ENTER to continue...
EOD
		read
		vi /data/data/com.topjohnwu.magisk/shared_prefs/com.topjohnwu.magisk_preferences.xml
	fi
}



tmpDir=/dev/mm_tmp
tmpf=$tmpDir/tmpf
tmpf2=$tmpDir/tmpf2
mountPath=/magisk

mount /data 2>/dev/null
mount /cache 2>/dev/null

[ -d /data/adb/magisk ] && IMG=/data/adb/magisk.img || IMG=/data/magisk.img

if [ ! -d /data/adb/magisk ] && [ ! -d /data/magisk ]; then
	echo -e "\n(!) No Magisk installation found or installed version is not supported\n"
	exit 1
fi

mkdir -p $tmpDir 2>/dev/null
mount_image $IMG $mountPath
cd $mountPath

echo -e "\nMagisk Manager for Recovery Mode (mm)
(c) 2017-2018, VR25 @ xda-developers
License: GPL v3+"

opts
