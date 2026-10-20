# ↩️ Back to Stock

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](kembali-ke-stok.md)

Want to remove TWRP and go back to the original? **No data is erased.** This is also how to fix a bootloop.

---

## Steps

1. Enter **FASTBOOT** mode: from a powered-off phone, hold **Power + Volume Down**.
2. Plug the cable into the PC.
3. Run **`2-KEMBALIKAN-STOK.bat`** (*restore stock*).
4. Wait for **BERHASIL** (*success*) — the phone restarts into normal HyperOS.

The script checks the stock file (SHA256) before writing, so it's safe.

## Without a PC (if TWRP still opens)

1. Download **`STOK-vendor_boot-<version>.img`** from [Releases](https://github.com/cogan17/TWRP-14T-PRO/releases) (version = your HyperOS), or take it from the package.
2. In TWRP: **Install → Install Image** → pick the STOK file → **Vendor Boot Image** → swipe.
3. **Reboot → System.** TWRP is gone and the phone is stock again — handy before taking an OTA.

---

## If the phone bootloops (stuck on the Mi logo)

1. Force it off: hold **Power ~15 seconds**.
2. Hold **Power + Volume Down** → **FASTBOOT**.
3. Run **`2-KEMBALIKAN-STOK.bat`**.

We never touch the bootloader, so FASTBOOT always works even if vendor_boot is broken.

> 💡 KernelSU modules disabled after a bootloop? That's an automatic safety measure. Re-enable them in the KernelSU app → Modules → reboot.
