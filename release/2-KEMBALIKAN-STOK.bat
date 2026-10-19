@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Kembalikan Stok - Xiaomi 14T Pro rothko
set "IMG=@STOCK_IMG@"
set "SHA=@STOCK_SHA256@"
echo.
echo  ==================================================
echo   KEMBALIKAN KE STOK - Xiaomi 14T Pro / rothko
echo   Untuk firmware @VERSION@
echo  ==================================================
echo.
echo  Ini menghapus TWRP dan mengembalikan HP seperti semula.
echo  Data di HP TIDAK dihapus.
echo.
call :siapkan
if errorlevel 1 goto gagal
echo  Langkah:
echo   1. Matikan HP. Kalau HP bootloop, tahan Power 10-15 detik sampai mati.
echo   2. Tahan tombol Power + Volume Bawah sampai muncul tulisan FASTBOOT.
echo   3. Sambungkan HP ke komputer dengan kabel USB.
echo.
pause
call :cek_hp
if errorlevel 1 goto gagal
echo.
echo  Mengembalikan file asli, jangan cabut kabel...
call fastboot flash vendor_boot "%IMG%"
if errorlevel 1 goto gagal_flash
echo.
echo  BERHASIL. HP dinyalakan ulang ke Android.
echo  Booting pertama bisa sampai 3 menit, tunggu saja.
call fastboot reboot >nul 2>&1
echo.
pause
exit /b 0

:siapkan
call fastboot --version >nul 2>&1
if errorlevel 1 goto no_fastboot
if not exist "%IMG%" goto no_file
echo  Memeriksa file stok...
set "H="
for /f "skip=1 delims=" %%a in ('certutil -hashfile "%IMG%" SHA256') do if not defined H set "H=%%a"
set "H=%H: =%"
if /i not "%H%"=="%SHA%" goto bad_file
echo  File stok OK.
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
echo  [!] Gagal menulis file. Jangan matikan HP. Jalankan skrip ini sekali lagi.
echo      Kalau tetap gagal, kirim pesan kesalahan di atas ke pembuat TWRP.
echo.
pause
exit /b 1
