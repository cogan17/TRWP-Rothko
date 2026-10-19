<h2 align="center">TWRP Device Tree for Xiaomi 14T Pro (rothko)</h2>

<p align="center">
  <img src="https://files.catbox.moe/66e3dq.png" alt="TWRP + Xiaomi Logo" width="260"/>
</p>

<p align="center">
  <i>The Xiaomi 14T Pro (codename <b>"rothko"</b>) is a high-end, mid-range smartphone from Xiaomi.<br/>
  Released in September 2024.</i>
</p>

---

## 📱 Device Specifications

<table align="center">
  <tr>
    <th align="center">Item</th>
    <th align="center">Details</th>
  </tr>
  <tr>
    <td align="center"><b>CPU</b></td>
    <td align="center">Octa-core CPU with 4× Arm Cortex-X4 up to 3,4GHz</td>
  </tr>
  <tr>
    <td align="center"><b>Chipset</b></td>
    <td align="center">Mediatek Dimensity 9300+</td>
  </tr>
  <tr>
    <td align="center"><b>GPU</b></td>
    <td align="center">Immortalis-G720 MC12</td>
  </tr>
  <tr>
    <td align="center"><b>Memory</b></td>
    <td align="center">12 / 16 GB RAM</td>
  </tr>
  <tr>
    <td align="center"><b>Shipped Android Version</b></td>
    <td align="center">14</td>
  </tr>
  <tr>
    <td align="center"><b>Storage</b></td>
    <td align="center">256 GB / 512 GB / 1 TB (UFS 4.0)</td>
  </tr>
  <tr>
    <td align="center"><b>Battery</b></td>
    <td align="center">Li-Po 5000 mAh, non-removable</td>
  </tr>
  <tr>
    <td align="center"><b>Display</b></td>
    <td align="center">1220 × 2712 px, 6.67", 60/120/144 Hz</td>
  </tr>
</table>

<p align="center">
  <img src="https://i02.appmifile.com/29_operator_sg/27/09/2024/22f8ea2494791d3811281f6cbdd69091.png"
       alt="Xiaomi 14T Pro" width="600"/>
</p>

---

## ✨ Features

**Works:**
- [x] ADB
- [x] Decryption (Android 16)
- [x] Display
- [x] Fastbootd
- [x] Flashing
- [x] MTP
- [x] Sideload
- [x] USB OTG
- [x] Vibrator
- [x] Miscellaneous

---

## 🔧 Perawatan

Semua lewat tab **Actions** di GitHub. Paket siap pakai selalu keluar dari **Verify TWRP image**.

| Kebutuhan | Langkah | Waktu |
|---|---|---|
| Ubah pengaturan, skrip atau file vendor di `recovery/root` | **Verify TWRP image**, isi `twrp_run_id` dengan run **Build TWRP** terakhir | ±3 menit |
| Versi TWRP baru | **Update TWRP sources**: `check` untuk melihat perubahan, `update` untuk mengunci versi baru (build berjalan otomatis) | ±1 jam, lebih cepat setelah cache terisi |
| Update HyperOS | **Extract stock blobs** (versi, link ROM, md5, sha256 `boot.img` dari HP), gabungkan cabang `stock/<versi>`, lalu **Verify TWRP image** dengan build terakhir | ±20 menit + 3 menit |
| Ubah kode, `BoardConfig.mk` atau `device.mk` | **Build TWRP** | ±1 jam |

Update HyperOS menimpa `vendor_boot`, jadi TWRP perlu dipasang lagi dengan paket untuk versi baru.
Kode TWRP dikunci di `.github/twrp-sources.lock.xml`; versi firmware tercatat di `.github/firmware.env`.

---

## 👤 Maintainer

- [cogan17](https://github.com/cogan17)

## 🙏 Credits

- [JonesqPacMan](https://github.com/JonesqPacMan/android_device_xiaomi_rothko_twrp): original rothko device tree this one is based on
- [TeamWin](https://github.com/TeamWin): TWRP
