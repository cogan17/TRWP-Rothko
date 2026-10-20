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

## 🔄 Sudah punya TWRP? Update tanpa FASTBOOT

**Lewat PC:** [masuk TWRP](masuk-twrp.md), colok kabel, lalu klik dua kali **`5-UPDATE-LEWAT-TWRP.bat`** dari paket (ekstrak ke folder `platform-tools` seperti biasa). Skrip mengecek file & HP, menulis TWRP, lalu memeriksa ulang hasil tulisannya.

**Tanpa PC:**

1. Di HP, buka **[Releases](https://github.com/cogan17/TWRP-14T-PRO/releases)** → unduh **`TWRP-rothko-<versi>.img`** saja (tidak perlu zip). Versinya harus **sama** dengan HyperOS-mu (*Setelan → Tentang ponsel*).
2. [Masuk TWRP](masuk-twrp.md) → buka kunci dengan [pola](enkripsi-dan-pola.md).
3. **Install** → tombol **Install Image** → buka folder `Download` → pilih `TWRP-rothko-<versi>.img`.
4. Pilih **Vendor Boot Image** → geser untuk flash.
5. **Reboot → Recovery.** Build terbaru punya file `/BUILD-INFO.txt` (lihat lewat *Advanced → File Manager*) berisi tanggal build-nya.

> ⚠️ Wajib pilih **Vendor Boot Image** — **jangan** Boot / Init_boot. Salah partisi = bootloop.

> 💡 Unduh juga **`STOK-vendor_boot-<versi>.img`** dan simpan di HP. Kalau Android tidak mau menyala tapi TWRP masih bisa dibuka, flash file STOK dengan cara yang sama. Kalau TWRP juga tidak bisa dibuka → pakai PC ([Kembali ke stok](kembali-ke-stok.md)).

---

## Cara unduh paket

1. Buka halaman **[Releases](https://github.com/cogan17/TWRP-14T-PRO/releases)**.
2. Pilih rilis terbaru (mis. `OS3.0.301.0.WNNIDXM`).
3. Di bagian **Assets**, klik **`PAKET-TWRP-rothko-...zip`** (~88 MB) — untuk pasang lewat PC.
   Update dari dalam TWRP? Cukup unduh **`TWRP-rothko-...img`**.

> Tidak perlu login — file rilis bisa langsung diunduh siapa saja.

## Isi paket

| File | Fungsi |
|---|---|
| `TWRP-rothko-*.img` | Image TWRP |
| `STOK-vendor_boot-*.img` | Cadangan stok (untuk kembali ke semula) |
| `1-PASANG-TWRP.bat` | Pasang TWRP |
| `2-KEMBALIKAN-STOK.bat` | [Kembali ke stok](kembali-ke-stok.md) |
| `3-AMBIL-LOG.bat` / `4-LOG-BOOTLOOP.bat` | [Ambil log](masalah-dan-log.md) |
| `5-UPDATE-LEWAT-TWRP.bat` | Update TWRP dari PC saat HP sudah di TWRP |
| `twrp-update.sh` | Dipakai otomatis oleh skrip 5 |
| `PANDUAN-TWRP.html` | Panduan offline |

## ⚠️ Penting

- Pasang **hanya** file untuk **rothko (14T Pro)** — jangan dari HP lain.
- `1-PASANG-TWRP.bat` memakai `fastboot reboot` biasa (bukan `reboot recovery`) — ini disengaja, lihat [kenapa](../arsip/developer.md#8-masuk-recovery).
