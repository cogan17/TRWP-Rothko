# 💾 Backup

[← Kembali ke README](../README.md) · <img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> [English](backup.en.md)

Selalu **backup dulu** sebelum bereksperimen. Datamu lebih berharga dari waktu.

---

## File pribadi (Download, DCIM, foto)

**Paling mudah — lewat Android biasa:**
colok kabel → pilih **Transfer File (MTP)** → salin folder ke PC.

**Lewat TWRP:**
1. [Masuk TWRP](masuk-twrp.md) → buka kunci dengan [pola](enkripsi-dan-pola.md).
2. Menu **Advanced → File Manager**.
3. Masuk `/sdcard` (atau `/data/media/0`), pilih folder, salin ke OTG/flashdisk.

## Partisi penting (init_boot, boot, super)

1. Di TWRP, buka menu **Backup**.
2. Centang partisi yang mau dicadangkan — umumnya **Boot**, **Init_boot**, **Super**.
3. Geser untuk memulai.
4. Hasil tersimpan di `TWRP/BACKUPS` di penyimpanan internal.

> ✅ Salin hasil backup ke PC/flashdisk juga, biar aman kalau HP bermasalah.

## Kapan ini berguna

- Sebelum update HyperOS, root, atau ganti ROM.
- `init_boot` = tempat root (KernelSU) — berguna kalau mau pulihkan root cepat.
