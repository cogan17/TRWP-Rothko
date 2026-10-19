@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Pasang TWRP - Xiaomi 14T Pro rothko
set "IMG=@TWRP_IMG@"
set "SHA=@TWRP_SHA256@"
echo.
echo  ==================================================
echo   PASANG TWRP - Xiaomi 14T Pro / rothko
echo   Untuk firmware @VERSION@
echo  ==================================================
echo.
echo  Data di HP TIDAK dihapus. Kalau ada masalah atau HP bootloop,
echo  jalankan 2-KEMBALIKAN-STOK.bat untuk mengembalikan seperti semula.
echo.
call :siapkan
if errorlevel 1 goto gagal
echo  Langkah:
echo   1. Matikan HP.
echo   2. Tahan tombol Power + Volume Bawah sampai muncul tulisan FASTBOOT.
echo   3. Sambungkan HP ke komputer dengan kabel USB.
echo.
pause
call :cek_hp
if errorlevel 1 goto gagal
echo.
echo  Memasang TWRP, jangan cabut kabel...
call fastboot flash vendor_boot "%IMG%"
if errorlevel 1 goto gagal_flash
echo.
echo  BERHASIL. HP sekarang masuk ke TWRP.
echo.
echo  PENTING untuk percobaan pertama:
echo   - Kalau TWRP minta PIN atau pola, tekan CANCEL dulu.
echo   - Coba sentuh layar. Kalau berfungsi, pilih Reboot lalu System.
echo   - Pastikan Android menyala normal.
echo  Kalau HP tidak masuk TWRP: matikan HP, lalu tahan Power + Volume Atas.
call fastboot reboot recovery >nul 2>&1
echo.
pause
exit /b 0

:siapkan
call fastboot --version >nul 2>&1
if errorlevel 1 goto no_fastboot
if not exist "%IMG%" goto no_file
echo  Memeriksa file TWRP...
set "H="
for /f "skip=1 delims=" %%a in ('certutil -hashfile "%IMG%" SHA256') do if not defined H set "H=%%a"
set "H=%H: =%"
if /i not "%H%"=="%SHA%" goto bad_file
echo  File TWRP OK.
echo.
exit /b 0
:no_fastboot
echo  [!] fastboot tidak ditemukan.
echo      Salin SEMUA file paket ini ke folder platform-tools, lalu jalankan lagi.
exit /b 1
:no_file
echo  [!] File %IMG% tidak ada di folder ini.
echo      Ekstrak ulang semua file dari zip paket ke folder yang sama.
exit /b 1
:bad_file
echo  [!] File %IMG% rusak atau bukan file yang benar.
echo      Unduh ulang paketnya.
exit /b 1

:cek_hp
set "DEV="
for /f %%a in ('fastboot devices 2^>nul') do set "DEV=%%a"
if not defined DEV goto no_hp
set "P="
for /f "tokens=1,2" %%a in ('fastboot getvar product 2^>^&1') do if /i "%%a"=="product:" set "P=%%b"
if not defined P goto wrong_hp
if /i not "%P%"=="rothko" goto wrong_hp
echo  HP terdeteksi: %P%
exit /b 0
:no_hp
echo  [!] HP belum terdeteksi dalam mode FASTBOOT.
echo      Pastikan layar HP bertuliskan FASTBOOT dan kabel tersambung, lalu jalankan lagi.
exit /b 1
:wrong_hp
echo  [!] Perangkat yang tersambung bukan Xiaomi 14T Pro - rothko. Terdeteksi: %P%
exit /b 1

:gagal
echo.
echo  Proses dihentikan. HP kamu TIDAK diubah.
echo.
pause
exit /b 1

:gagal_flash
echo.
echo  [!] Gagal memasang TWRP. Jalankan 2-KEMBALIKAN-STOK.bat sekarang,
echo      lalu kirim pesan kesalahan di atas ke pembuat TWRP.
echo.
pause
exit /b 1
