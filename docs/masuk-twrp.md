# 🔑 Masuk TWRP

[← Kembali ke README](../README.md) · <img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> [English](masuk-twrp.en.md)

Ada dua cara masuk ke TWRP. Keduanya aman.

---

## Cara 1 — Tombol (dari HP mati)

1. Matikan HP sampai benar-benar mati.
2. Tahan **Volume Atas + Power** bersamaan.
3. Saat logo Mi muncul, **lepas Power** tapi tahan terus **Volume Atas** sebentar, sampai TWRP terbuka.

## Cara 2 — Termux (butuh root, paling cepat)

HP sudah root (KernelSU)? Cukup:

```sh
su -c 'reboot recovery'
```

(KernelSU akan minta izin root untuk Termux pertama kali — **Izinkan**.)

---

## ⚠️ Jangan pakai "reboot recovery" kalau TWRP sedang bermasalah

Perintah `reboot recovery` menulis tanda **BCB** di partisi `misc`. Kalau TWRP-nya crash, HP bisa **bootloop** terus. Dengan TWRP yang sudah berfungsi, ini aman — TWRP membersihkan tanda itu saat menyala. Penjelasan teknis: [Catatan Developer → Masuk recovery](../arsip/developer.md#8-masuk-recovery).

Keluar dari TWRP → **Reboot → System**.
