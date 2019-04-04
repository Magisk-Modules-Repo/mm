#!/system/bin/sh
# remove leftovers

(until [ -f /data/media/0/mm ]; do sleep 20; done
rm /data/media/0/mm &) &
exit 0
