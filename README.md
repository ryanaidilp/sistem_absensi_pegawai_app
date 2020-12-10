<p align="center">
    <img src="https://i.ibb.co/jGgBj1n/icon.png"/>
</p>

<h1 align="center">SIAP</h1>

Aplikasi Android untuk manajemen data presensi pegawai di lingkungan kantor pemerintahan Kecamatan Balaesang. Aplikasi ini dibangun dengan [Flutter](https://flutter.dev)

[![SIAP](https://i.ibb.co/5c35JYp/banner.png)](https://play.google.com/store/apps/details?id=com.banuacoders.siap)

## About

Aplikasi ini dibangun untuk mengatasi permasalahan pencatatan absensi pegawai di lingkungan kantor pemerintahan Kecamatan Balaesang. Pencatatan kehadiran pegawai di kantor pemerintahan Kecamatan Balaesang selama ini masih dilakukan secara manual yaitu dengan memberi paraf pada absensi.

Permasalahan timbul saat sebagian besar pegawai tidak jujur dalam mengisi absen tersebut, ada yang titip ke teman untuk diparaf namanya, ada yang langsung isi absen sampai beberapa hari ke depan, ada yang mengisi absen diluar waktunya, dsb. Dengan adanya sistem ini, diharapkan bisa membantu mengatasi permasalahan-permasalahan yang telah disebutkan.

## Konfigurasi

*Clone* repository back-end aplikasinya [disini](https://github.com/ryanaidilp/sistem_absensi_pegawai). Buat file **.env** pada root folder aplikasi ini lalu tambahkan variabe berikut

```dotenv
    BASE_URL="BASE URL ONLINE"
    LOCAL_URL="LOCAL_URL" #Jika kamu ingin menyambungkian ke server di localhost
    ONE_SIGNAL_APP_ID="APP ID UNTUK ONE SIGNAL"
``` 
Isikan variabel sesuai dengan konfigurasi anda.

## Screenshoot

- *Login Screen*
  ![Login Screen](https://i.ibb.co/fxCP1FX/login.png)

- *Home*
![Home](https://i.ibb.co/WcPfmKm/home.png)

- Absensi (*QR Scanner*)
  ![Scanner](https://i.ibb.co/5kXRkRM/presensi.png)

- Daftar Absensi
  ![Attendance List](https://i.ibb.co/fCPk4Pn/absent-list.png)

- Daftar Pegawai
  ![Employee List](https://i.ibb.co/0939TPX/employee-list.png)

- Ubah Password
  ![Change Password](https://i.ibb.co/FKk6Vzv/change-pass.png)

- Pengajuan Izin
![Create Permission](https://i.ibb.co/GM2rQjH/create-permission.png)

- Daftar Izin yang diajukan
  ![Permission List](https://i.ibb.co/FmgzWKF/permission-list.png)