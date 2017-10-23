#!/sbin/sh
# Magisk Manager for Recovery Mode
# VR25 @ XDA Developers


# ENVIRONMENT

VesionCode=201710230
img=/data/magisk.img
mntpt=/magisk
TMPDIR=/dev/tmpd
PATH=$PATH:/data/magisk:$TMPDIR
{ busybox mkdir $TMPDIR
busybox --install -s $TMPDIR
mkdir $mntpt
mount /data
mount /cache
mount $img $mntpt; } 2>/dev/null
tmpf=$TMPDIR/tmpf
tmpf2=$TMPDIR/tmpf2
first_run=true
cd $mntpt


# Detect whether in boot mode
ps | grep zygote | grep -v grep >/dev/null && BOOTMODE=true || BOOTMODE=false
$BOOTMODE || ps -A 2>/dev/null | grep zygote | grep -v grep >/dev/null && BOOTMODE=true

$BOOTMODE && echo \
	&& echo "I saw what you did there... :)" \
	&& echo "- Bad idea!" \
	&& echo "- This is meant to be used in recovery mode only." \
	&& echo \
	&& exit 1

 
# ENGINE

actions() {
	echo
	cat <<EOL
e. Enable/disable modules
f. Fix magisk.img (e2fsck -fy)
l. List installed modules
r. Resize magisk.img
t. Toggle auto_mount
u. Uninstall modules
---
x. Exit
EOL
	read INPUT
	echo
}


exit_or_not() {
	echo
	echo "Would you like to do anything else? (y/N)"
	read ans
	echo $ans | grep -iq y && opts || exxit
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


if ! mountpoint -q $mntpt; then
	echo "(!) mm: $img mount failed"
	exxit 1
fi


auto_mnt() { auto_mount=true; toggle auto_mount auto_mount rm touch; }


enable_disable_mods() { auto_mount=false; toggle "Module ON/OFF" disable touch rm; }


exxit() {
	{ umount /system/bin
	umount /system
	umount $mntpt
	umount /data
	umount /cache
	rmdir $mntpt; } 2>/dev/null
	echo

	if [ "$1" != "1" ]; then
		echo "Goodbye"
		echo
		exit 0
	elif [ "$1" = "0" ]; then exit 0
	else exit 1
	fi
}


fix_img() {
	echo "<e2fsck -fy magisk.img>"
	e2fsck -fy $img
	echo
	echo Done
}


list_mods() {
	echo
	echo "<Installed Modules>"
	echo
	mod_ls
	echo
}


opts() {
	if $first_run; then
		echo
		echo "Magisk Manager"
	else echo; fi
	echo
	echo "Pick an option..."
	actions

	case "$INPUT" in
		e ) enable_disable_mods;;
		f ) fix_img;;
		l ) list_mods;;
		r ) resize_img;;
		t ) auto_mnt;;
		u ) rm_mods;;
		x ) exxit;;
		* ) opts;;
	esac

	first_run=false
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
	echo
	read INPUT
	if [ "$INPUT" ]; then
		resize2fs $img ${INPUT}M
		echo
		echo Done
	else
		echo "(i) Operation aborted: null input"
	fi
}


rm_mods() { 
	: > $tmpf
	: > $tmpf2
	INPUT=0
	list_mods
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


opts
