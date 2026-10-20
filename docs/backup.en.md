# 💾 Backup

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](backup.md)

Always **back up first** before experimenting. Your data is worth more than your time.

---

## Personal files (Download, DCIM, photos)

**Easiest — from normal Android:**
plug in the cable → choose **File Transfer (MTP)** → copy the folders to your PC.

**From TWRP:**
1. [Enter TWRP](masuk-twrp.en.md) → unlock with your [pattern](enkripsi-dan-pola.en.md).
2. **Advanced → File Manager**.
3. Go to `/sdcard` (or `/data/media/0`), select a folder, copy it to OTG / a flash drive.

## Key partitions (init_boot, boot, super)

1. In TWRP, open **Backup**.
2. Tick the partitions to back up — usually **boot**, **init_boot**, **super**.
3. Swipe to start.
4. The result is saved in `TWRP/BACKUPS` on internal storage.

> ✅ Copy the backup to a PC / flash drive too, in case the phone has problems.

## When this helps

- Before a HyperOS update, rooting, or changing ROM.
- `init_boot` = where root (KernelSU) lives — handy to restore root quickly.
