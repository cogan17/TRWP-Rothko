# 🩺 Masalah & Log

[← Kembali ke README](../README.md)

Kalau ada kendala, **jangan menebak** — ambil log dan kirim. Log menunjukkan persis di mana gagalnya.

---

## Skrip log mana yang dipakai?

| Situasi | Skrip | Yang diambil |
|---|---|---|
| TWRP jalan, tapi ada masalah (sentuh, pola, mount) | **`3-AMBIL-LOG.bat`** | `recovery.log`, dmesg, logcat, dll |
| HP **bootloop** / tak mau boot | **`4-LOG-BOOTLOOP.bat`** | `console-ramoops-0` (log boot yang gagal) + `recovery.log` |

Keduanya menyimpan hasil ke folder **`Downloads`** di PC, lalu membuka foldernya otomatis.

## Untuk bootloop — penting urutannya

`console-ramoops-0` = catatan detik-detik boot gagal. Supaya masih utuh:
1. **Jangan matikan paksa** saat bootloop.
2. Masuk TWRP langsung dari kondisi bootloop (**Volume Atas + Power**).
3. Baru jalankan `4-LOG-BOOTLOOP.bat`.

## Yang paling berguna dikirim

- `recovery.log` — untuk hampir semua masalah TWRP.
- `console-ramoops-0` — untuk bootloop.

---

## Masalah umum

| Gejala | Kemungkinan | Lihat |
|---|---|---|
| Bootloop logo Mi | image rusak / salah paket | [Kembali ke stok](kembali-ke-stok.md) |
| "Failed to decrypt" / pola gagal | protektor / pola | [Enkripsi & Pola](enkripsi-dan-pola.md) |
| Layar tidak bisa disentuh | mode THP touch | [Catatan Developer §6](../arsip/developer.md#6-touch-focaltech-mulai-di-mode-thp) |
| Download/DCIM kosong | data belum didekripsi | buka pola dulu |
