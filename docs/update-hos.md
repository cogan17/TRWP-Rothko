# 🔄 Update HyperOS Tanpa Kehilangan Data

[← Kembali ke README](../README.md)

Saat HyperOS keluar update, TWRP & root biasanya **ikut hilang**. Ini cara update yang **aman** — datamu tetap utuh, tanpa restore yang berisiko.

---

## ✅ Cara aman (disarankan)

Dengan cara ini datamu **terbawa sendiri**, jadi **tidak perlu restore `/data` manual** (dan tidak ada risiko bentrok):

1. **Backup dulu** — data, file pribadi, **dan** partisi `boot`/`init_boot`/`vendor_boot`. Lihat [Backup](backup.md). Ini jaring pengaman.
2. **[Kembali ke stok](kembali-ke-stok.md)** dulu (buang TWRP/root) — OTA sering **gagal** kalau partisi masih termodifikasi.
3. **Ambil OTA dari Setelan → JANGAN wipe.** OTA **tidak** menghapus `/data`, jadi aplikasi & datamu tetap ada.
4. **Pasang TWRP + root lagi** (versi yang cocok dengan HOS baru).

> 💡 Intinya: biarkan OTA bawa datamu sendiri. Restore manual itu pilihan terakhir.

---

## ⚠️ Jangan restore backup `/data` lama ke HOS versi beda

Ini kesalahan yang paling sering bikin HP bermasalah. Restore full `/data` **hanya aman ke versi OS yang SAMA**.

Kenapa bentrok? Di `/data` ada **data sistem** (`/data/system`) yang menyimpan **kunci kunci-layar + enkripsi** (pola/PIN), terikat ke build HOS lama + chip keamanan. Kalau ditimpa ke HOS baru, gejalanya khas:

- 🔒 Pola/PIN **ditolak**, data **gagal didekripsi**.
- 💥 Settings / SystemUI **force close**, atau **bootloop**.

---

## Kalau tetap harus pindah data antar-versi

Jangan full `/data`. Pisahkan:

| Jenis | Cara | Aman? |
|---|---|---|
| **File pribadi** (foto, Download, dokumen) | salin biasa lewat MTP / File Manager | ✅ selalu aman |
| **Aplikasi + datanya** | pakai app backup: **Swift Backup** / **Neo Backup** | ✅ aman (tak sentuh data sistem) |
| **Full `/data` (.win)** | restore TWRP | ⛔ hanya ke versi OS yang sama |

---

## Jebakan yang sering bikin kaget

Backup **"Data"** di TWRP **secara default TIDAK termasuk foto/internal storage** (`/data/media`). Jadi kalau cuma backup "Data", **foto-fotomu belum ter-backup.** Centang juga internal storage, atau salin manual lewat MTP.

> **Aturan emas:** OTA tanpa wipe = data aman otomatis. Restore `/data` = cuma ke versi OS yang sama.
