# ↩️ Kembali ke Stok

[← Kembali ke README](../README.md)

Mau menghapus TWRP dan kembali seperti semula? **Data tidak dihapus.** Ini juga cara memperbaiki bootloop.

---

## Langkah

1. Masuk mode **FASTBOOT**: dari HP mati, tahan **Power + Volume Bawah**.
2. Colok kabel ke PC.
3. Jalankan **`2-KEMBALIKAN-STOK.bat`**.
4. Tunggu sampai **BERHASIL** — HP menyala ulang ke HyperOS normal.

Skrip memeriksa file stok (cek SHA256) sebelum menulis, jadi aman.

## Tanpa PC (kalau TWRP masih bisa dibuka)

1. Unduh **`STOK-vendor_boot-<versi>.img`** dari [Releases](https://github.com/cogan17/TWRP-14T-PRO/releases) (versi = HyperOS-mu), atau ambil dari isi paket.
2. Di TWRP: **Install → Install Image** → pilih file STOK → **Vendor Boot Image** → geser.
3. **Reboot → System.** TWRP hilang, HP kembali stok — cocok sebelum ambil OTA.

---

## Kalau HP bootloop (muter di logo Mi)

1. Paksa mati: tahan **Power ~15 detik**.
2. Tahan **Power + Volume Bawah** → **FASTBOOT**.
3. Jalankan **`2-KEMBALIKAN-STOK.bat`**.

Bootloader tidak pernah kita sentuh, jadi FASTBOOT selalu bisa diakses walau vendor_boot rusak.

> 💡 Modul KernelSU mati setelah bootloop? Itu pengaman otomatis. Nyalakan lagi di aplikasi KernelSU → Modul → reboot.
