# 📥 Install TWRP

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](pasang.md)

Install TWRP on the Xiaomi 14T Pro (rothko) with **platform-tools** and the ready-made `.bat` scripts. No commands to type.

> The scripts and their on-screen messages are in Indonesian; the key words are translated below.

---

## What you need

| | |
|---|---|
| 💻 A **Windows** PC | + a good USB cable |
| 📂 **platform-tools** | contains `adb.exe` & `fastboot.exe` |
| 🔓 Bootloader | **unlocked** |
| 🔋 Battery | at least **50%** |

## Steps

1. **Download the package** (see [how to download](#how-to-download-the-package) below), then **extract everything** into the `platform-tools` folder (overwrite if asked).
2. Turn the phone off. Hold **Power + Volume Down** until **FASTBOOT** appears.
3. Connect the phone to the PC with the cable.
4. Open the `platform-tools` folder and double-click **`1-PASANG-TWRP.bat`** (*install TWRP*).
5. Follow the on-screen instructions. Wait for **BERHASIL** (*success*) — the phone boots into Android by itself.

> ✅ If you see `HP terdeteksi: rothko` (*phone detected*) and then `BERHASIL`, the install worked.

Next: [how to enter TWRP →](masuk-twrp.en.md)

---

## 🔄 Already have TWRP? Update without FASTBOOT

**From a PC:** [enter TWRP](masuk-twrp.en.md), plug in the cable, then double-click **`5-UPDATE-LEWAT-TWRP.bat`** (*update via TWRP*) from the package (extracted into `platform-tools` as usual). The script checks the file and the phone, writes TWRP, then reads back what it wrote.

**Without a PC:**

1. On the phone, open **[Releases](https://github.com/cogan17/TWRP-14T-PRO/releases)** → download only **`TWRP-rothko-<version>.img`** (no zip needed). The version must **match** your HyperOS (*Settings → About phone*).
2. [Enter TWRP](masuk-twrp.en.md) → unlock with your [pattern](enkripsi-dan-pola.en.md).
3. **Install** → **Install Image** button → open the `Download` folder → pick `TWRP-rothko-<version>.img`.
4. Choose **vendor_boot** → swipe to flash.
5. **Reboot → Recovery.** Recent builds include `/BUILD-INFO.txt` (see *Advanced → File Manager*) with the build date.

> ⚠️ You must choose **vendor_boot** — **not** boot / init_boot. Wrong partition = bootloop.

> 💡 Also download **`STOK-vendor_boot-<version>.img`** (*stock*) and keep it on the phone. If Android won't start but TWRP still opens, flash the STOK file the same way. If TWRP won't open either → use a PC ([Back to stock](kembali-ke-stok.en.md)).

---

## How to download the package

1. Open the **[Releases](https://github.com/cogan17/TWRP-14T-PRO/releases)** page.
2. Pick the latest release (e.g. `OS3.0.301.0.WNNIDXM`).
3. Under **Assets**, click **`PAKET-TWRP-rothko-...zip`** (*package*, ~88 MB) — for installing from a PC.
   Updating from inside TWRP? Just download **`TWRP-rothko-...img`**.

> No login needed — anyone can download release files.

## What's in the package

| File | Purpose |
|---|---|
| `TWRP-rothko-*.img` | TWRP image |
| `STOK-vendor_boot-*.img` | Stock backup (to go back to the original) |
| `1-PASANG-TWRP.bat` | Install TWRP |
| `2-KEMBALIKAN-STOK.bat` | [Back to stock](kembali-ke-stok.en.md) |
| `3-AMBIL-LOG.bat` / `4-LOG-BOOTLOOP.bat` | [Collect logs](masalah-dan-log.en.md) |
| `5-UPDATE-LEWAT-TWRP.bat` | Update TWRP from a PC while the phone is in TWRP |
| `twrp-update.sh` | Used automatically by script 5 |
| `PANDUAN-TWRP.html` | Offline guide (Indonesian) |

## ⚠️ Important

- Install **only** files made for **rothko (14T Pro)** — never from another phone.
- `1-PASANG-TWRP.bat` uses a plain `fastboot reboot` (not `reboot recovery`) on purpose — see [why](../arsip/developer.en.md#8-entering-recovery).
