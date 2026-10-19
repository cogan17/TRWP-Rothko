@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Ambil Log Bootloop - Xiaomi 14T Pro rothko
rem Bootloop = boot normal gagal. Yang penting di sini bukan log TWRP biasa,
rem tapi catatan kernel dari boot yang gagal: /sys/fs/pstore/console-ramoops-0
set "OUT=%USERPROFILE%\Downloads\LOG-BOOTLOOP"
echo.
echo  ==================================================
echo   AMBIL LOG BOOTLOOP - Xiaomi 14T Pro / rothko
echo  ==================================================
echo.
echo  CARA PAKAI (penting, baca dulu):
echo   1. Kalau HP sedang bootloop di logo Mi, JANGAN matikan paksa.
echo   2. Tahan Volume Atas + Power sampai masuk TWRP.
echo   3. Sambungkan kabel USB ke komputer.
echo   4. Baru tekan tombol di bawah ini.
echo.
echo  (Masuk TWRP langsung dari kondisi bootloop membuat catatan
echo   boot-gagal-nya masih utuh. Itu yang saya butuhkan.)
echo.
pause
call adb version >nul 2>&1
if errorlevel 1 goto no_adb
set "M="
for /f "skip=1 tokens=1,2" %%a in ('adb devices 2^>nul') do if not "%%b"=="" set "M=%%b"
if not defined M goto no_hp
echo  HP terdeteksi, mode: %M%
if not exist "%OUT%" mkdir "%OUT%"
if not exist "%OUT%" goto no_folder
echo  Mengambil log, tunggu sebentar...
rem Catatan kernel dari boot yang gagal (paling penting)
call adb pull /sys/fs/pstore "%OUT%\pstore" >nul 2>&1
call adb pull /sys/fs/pstore/console-ramoops-0 "%OUT%\console-ramoops-0.txt" >nul 2>&1
rem Log TWRP yang sedang jalan + info tambahan
call adb pull /tmp/recovery.log "%OUT%\recovery.log" >nul 2>&1
call adb shell dmesg > "%OUT%\dmesg-twrp.txt" 2>&1
call adb shell getprop > "%OUT%\getprop.txt" 2>&1
rem Apakah ada yang berhasil? console-ramoops ATAU recovery.log sudah cukup
set "OKFILE="
if exist "%OUT%\console-ramoops-0.txt" set "OKFILE=1"
if exist "%OUT%\pstore\console-ramoops-0" set "OKFILE=1"
if exist "%OUT%\recovery.log" set "OKFILE=1"
if not defined OKFILE goto gagal_ambil
echo.
echo  SELESAI. Log tersimpan di:
echo    %OUT%
echo  Folder dibuka sekarang. Kirim SEMUA file di dalamnya.
echo  Yang paling penting: console-ramoops-0 (catatan boot yang gagal).
call explorer "%OUT%"
echo.
echo  HP TIDAK dinyalakan ulang. Kamu masih di TWRP, bisa langsung
echo  jalankan 2-KEMBALIKAN-STOK.bat kalau mau balik normal dulu.
echo.
pause
exit /b 0

:no_adb
echo  [!] adb tidak ditemukan.
echo      Salin file ini ke folder platform-tools, lalu jalankan lagi.
goto selesai
:no_folder
echo  [!] Tidak bisa membuat folder %OUT%
goto selesai
:gagal_ambil
echo  [!] Tidak ada log yang terambil.
echo      Pastikan HP sudah MASUK TWRP (bukan masih di logo Mi),
echo      lalu cabut-pasang kabel dan jalankan skrip ini lagi.
goto selesai
:no_hp
echo  [!] HP belum terdeteksi.
echo      Berarti TWRP belum jalan. Dari kondisi bootloop:
echo       1. Tahan Volume Atas + Power sampai masuk TWRP.
echo       2. Sambungkan kabel, jalankan skrip ini lagi.
:selesai
echo.
pause
exit /b 1
