#!/system/bin/sh
# TWRP runs this when the screen turns back on. Screen-on resets the touch chip, so once
# the reset is done switch THP raw frames off again (see init.recovery.mt6989.rc)
(sleep 1; echo 0 > /sys/class/touch/touch_dev/enable_touch_raw) >/dev/null 2>&1 &
