#!/sbin/sh
# Magisk Manager for Recovery Mode
# VR25 @ XDA Developers


# ENVIRONMENT

[ -f /data/media/magisk.img ] && img=/data/media/magisk.img || img=/data/magisk.img

if [ ! -d /data/magisk ]; then
	echo
	echo "(!) Magisk is not installed."
	echo
	exit 1
fi

if [ ! -f $img ]; then
	echo
	echo "(!) magisk.img doesn't exist."
	echo
	exit 1
fi

# Set up Magisk's busybox
bpath=/data/magisk/busybox
if [ -f $bpath ]; then
	alias busybox=$bpath
	for i in $(busybox --list); do
		alias $i="$bpath $i"
	done
fi

mount_img() {
	# Detect whether in boot mode
	ps | grep zygote | grep -v grep >/dev/null && BOOTMODE=true || BOOTMODE=false
	$BOOTMODE || ps -A 2>/dev/null | grep zygote | grep -v grep >/dev/null && BOOTMODE=true

	if $BOOTMODE; then
		echo
		echo "I saw what you did there... :)"
		echo "- Bad idea!"
		echo "- This is meant to be used in recovery mode only."
		echo
		exit 1
	fi
	
	mkdir $2 2>/dev/null
    mount $img $mntpt
  
	if ! mountpoint -q $mntpt; then
		echo
		echo "(!) $img mount failed"
		echo
		exit 1
	fi
}

echo
echo "Magisk Manager"
echo
mntpt=/magisk
TMPDIR=/dev/tmpd/mm
{ rm -rf $TMPDIR
mkdir -p $TMPDIR
mount /data
mount /cache
mount_img $img $mntpt; } 2>/dev/null

tmpf=$TMPDIR/tmpf
tmpf2=$TMPDIR/tmpf2
first_run=true
cd $mntpt


# ENGINE

actions() {
	echo
	cat <<EOL
e) Enable/disable modules
f) Fix magisk.img (e2fsck -fy)
l) List installed modules
m) Make magisk.img survive f. resets
r) Resize magisk.img
s) Change Magisk settings (WIP)
t) Toggle auto_mount
u) Uninstall modules
---
x. Exit
EOL
	read INPUT
	echo
}


exit_or_not() {
	echo
	echo "Would you like to do anything else? (Y/n)"
	read ans
	echo $ans | grep -iq n && echo && exxit || opts
}


mod_ls() { ls -1 $mntpt | grep -v 'lost+found'; }


toggle() {
	echo "<Toggle $1>" 
	: > $tmpf
	: > $tmpf2
	INPUT=0
	
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
	
	echo "Input a matching WORD/string at once"
	echo "- Press RETURN when done (or to cancel)"
	echo "-- CTRL+C to exit"

	until [ -z "$INPUT" ]; do
		read INPUT
		if [ "$INPUT" ]; then
			grep "$INPUT" $tmpf | grep -q '(ON)' && \
				echo "$3 $(grep "$INPUT" $tmpf | grep '(ON)')/$2" >> $tmpf2
			grep "$INPUT" $tmpf | grep -q '(OFF)' && \
				echo "$4 $(grep "$INPUT" $tmpf | grep '(OFF)')/$2" >> $tmpf2
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
		echo "(i) Operation aborted: null input"
	fi
}


auto_mnt() { auto_mount=true; toggle auto_mount auto_mount rm touch; }


enable_disable_mods() { auto_mount=false; toggle "Module ON/OFF" disable touch rm; }


exxit() {
	{ umount /system/bin
	umount /system
	umount $mntpt
	umount /data
	umount /cache
	rmdir $mntpt; } 2>/dev/null

	if [ "$1" != "1" ]; then
		echo "Goodbye."
		echo
		exit 0
	elif [ "$1" = "0" ]; then exit 0
	else exit 1
	fi
}


fix_img() {
	echo "<e2fsck -fy magisk.img>"
	echo
	e2fsck -fy $img
}


list_mods() {
	echo "<Installed Modules>"
	echo
	mod_ls
}


opts() {
	echo
	echo "Pick an option..."
	actions

	case "$INPUT" in
		e ) enable_disable_mods;;
		f ) fix_img;;
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
	echo "<Resize magisk.img>"
	echo
	df -h $mntpt
	echo
	echo "Input the desired size in MB"
	echo "- Or nothing to cancel"
	echo "- Press CTRL+C to exit"
	read INPUT
	if [ "$INPUT" ]; then
		echo
		resize2fs $img ${INPUT}M
	else
		echo "(i) Operation aborted: null input"
	fi
}


rm_mods() { 
	: > $tmpf
	: > $tmpf2
	INPUT=0
	list_mods
	echo
	echo "Input a matching WORD/string at once"
	echo "- Press RETURN when done (or to cancel)"
	echo "-- CTRL+C to exit"

	until [ -z "$INPUT" ]; do
		read INPUT
		[ "$INPUT" ] && mod_ls | grep "$INPUT" \
			| sed 's/^/rm -rf /' >> $tmpf \
			&& mod_ls | grep "$INPUT" >> $tmpf2
	done

	if grep -Eq '[0-9]|[a-z]|[A-Z]' $tmpf; then
		. $tmpf
		echo "Removed Module(s):"
		cat $tmpf2
	else
		echo "(i) Operation aborted: null input"
	fi
}


immortal_m() {
	if [ ! -f /data/media/magisk.img ]; then
		err() { echo "$1"; exit_or_not; }
		echo "mv /data/magisk.img /data/media"
		mv /data/magisk.img /data/media \
			&& echo "ln -s /data/media/magisk.img /data" \
			&& ln -s /data/media/magisk.img /data \
			&& echo "- All set." \
			&& echo \
			&& echo "(i) Run this again right after factory resets to recreate the symlink." \
			|| err "- (!) magisk.img couldn't be moved."
		
	else echo "(i) Fresh ROM, uh?"
		echo "ln -s /data/media/magisk.img /data"
		ln -s /data/media/magisk.img /data \
		&& echo "- All set."
	fi
}


m_settings() {
	echo "(i) function not fully implemented (WIP)"
	#prefs=/data/data/com.topjohnwu.magisk/shared_prefs/com.topjohnwu.magisk_preferences.xml
	#y=true
	#n=false
	
	#c() { sed -i "/disable/s/false/$y" $prefs; }
	#d() {
		
	#h() {
		
	#n() {
		
	
	#list all
	#prompt for function + bool y/n or t/f
	#use for loop to separate function from bool & run
	
}


opts
