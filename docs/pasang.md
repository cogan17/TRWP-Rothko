# 📥 Pasang TWRP

[← Kembali ke README](../README.md)

Memasang TWRP ke Xiaomi 14T Pro (rothko) lewat **platform-tools** dan skrip `.bat` yang sudah disediakan. Tidak perlu mengetik perintah manual.

---

## Yang perlu disiapkan

| | |
|---|---|
| 💻 Komputer **Windows** | + kabel USB yang bagus |
| 📂 **platform-tools** | berisi `adb.exe` & `fastboot.exe` |
| 🔓 Bootloader | sudah **ter-unlock** |
| 🔋 Baterai | minimal **50%** |

## Langkah

1. **Unduh paket** TWRP (lihat [cara unduh](#cara-unduh-paket) di bawah), lalu **ekstrak semua isinya** ke dalam folder `platform-tools` (timpa kalau ada yang sama).
2. Matikan HP. Tahan **Power + Volume Bawah** sampai muncul tulisan **FASTBOOT**.
3. Sambungkan HP ke komputer dengan kabel.
4. Buka folder `platform-tools`, klik dua kali **`1-PASANG-TWRP.bat`**.
5. Ikuti petunjuk di layar. Tunggu sampai tertulis **BERHASIL** — HP menyala sendiri ke Android.

> ✅ Kalau muncul `HP terdeteksi: rothko` lalu `BERHASIL`, pemasangan sukses.

Lanjut: [cara masuk TWRP →](masuk-twrp.md)

---

## Cara unduh paket

1. Buka halaman **[Releases](https://github.com/cogan17/TRWP-Rothko/releases)**.
2. Pilih rilis terbaru (mis. `OS3.0.301.0.WNNIDXM`).
3. Di bagian **Assets**, klik **`PAKET-TWRP-rothko-...zip`** (~88 MB).

> Tidak perlu login — file rilis bisa langsung diunduh siapa saja.

## Isi paket

| File | Fungsi |
|---|---|
| `TWRP-rothko-*.img` | Image TWRP |
| `STOK-vendor_boot-*.img` | Cadangan stok (untuk kembali ke semula) |
| `1-PASANG-TWRP.bat` | Pasang TWRP |
| `2-KEMBALIKAN-STOK.bat` | [Kembali ke stok](kembali-ke-stok.md) |
| `3-AMBIL-LOG.bat` / `4-LOG-BOOTLOOP.bat` | [Ambil log](masalah-dan-log.md) |
| `PANDUAN-TWRP.html` | Panduan offline |

## ⚠️ Penting

- Pasang **hanya** file untuk **rothko (14T Pro)** — jangan dari HP lain.
- `1-PASANG-TWRP.bat` memakai `fastboot reboot` biasa (bukan `reboot recovery`) — ini disengaja, lihat [kenapa](../arsip/developer.md#8-masuk-recovery).
