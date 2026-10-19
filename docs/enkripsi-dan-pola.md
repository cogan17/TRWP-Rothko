# 🔐 Enkripsi & Pola

[← Kembali ke README](../README.md)

Data di HP terenkripsi (FBE). TWRP perlu **pola/sandi yang sama** dengan layar kunci untuk membukanya.

---

## Membuka data

Saat masuk TWRP, akan muncul permintaan pola:

- **Pengguna utama (0):** gambar **pola** yang sama seperti layar kunci — **sekali, teliti**. Kalau benar, Download/DCIM langsung terlihat.
- **XSpace / Ruang Kedua (999):** profil terpisah dengan **sandi sendiri**. Masukkan sandinya kalau kamu pakai; kalau tidak, **lewati** — data utama tetap terbuka.

## Ganti pola? TWRP otomatis ikut

Kalau kamu ganti pola di Android, TWRP akan minta **pola baru** (pola lama tidak berlaku lagi). Sudah terbukti bekerja di HP ini.

> Tetap disarankan **tes sekali** setelah ganti pola (masuk TWRP, coba pola baru), setelah data penting di-backup.

## ⚠️ Jangan ulang pola berkali-kali

Salah berulang bisa kena **kunci sementara** (gatekeeper throttle). Cukup sekali kalau yakin. Kalau gagal, [ambil log](masalah-dan-log.md) — jangan terus mencoba.

---

## Kenapa ini rumit di HP ini? (singkat)

HyperOS menyimpan kunci utama di **Weaver** (chip keamanan NXP) yang tidak bisa diakses recovery, tapi juga menyimpan pelindung **Gatekeeper** untuk pola yang sama. TWRP memakai jalur Gatekeeper itu. Detail teknis: [Catatan Developer](developer.md#4-hyperos-lskf-weaver-aktif-gatekeeper-cadangan).
