# Run inside TWRP by 5-UPDATE-LEWAT-TWRP.bat (adb shell); prints one status word for the .bat
f=/tmp/twrp-baru.img
sha=@TWRP_SHA256@
p=/dev/block/by-name/vendor_boot$(getprop ro.boot.slot_suffix)
[ "$(getprop ro.product.device)" = rothko ] || { echo HP_LAIN; exit 1; }
[ -b "$p" ] || { echo TIDAK_ADA_PARTISI; exit 1; }
[ "$(sha256sum "$f" | cut -d' ' -f1)" = "$sha" ] || { echo KIRIM_RUSAK; exit 1; }
dd if="$f" of="$p" bs=4194304 2>/dev/null && sync || { echo TULIS_GAGAL; exit 1; }
# read back: a short or failed write must not pass as success (unquoted $n drops wc padding)
n=$(wc -c < "$f")
[ "$(head -c $n "$p" | sha256sum | cut -d' ' -f1)" = "$sha" ] || { echo TULIS_GAGAL; exit 1; }
rm -f "$f"
echo SELESAI
