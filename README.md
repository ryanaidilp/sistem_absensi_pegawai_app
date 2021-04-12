<p align="center">
    <img src="https://i.ibb.co/jGgBj1n/icon.png" height="200"/>
</p>

<h1 align="center">SiAP</h1>

Aplikasi Android untuk manajemen data presensi pegawai di lingkungan kantor pemerintahan Kecamatan Balaesang. Aplikasi ini dibangun dengan [Flutter](https://flutter.dev)

[![SIAP](https://i.ibb.co/Xz9Dppd/thumb.png)](https://play.google.com/store/apps/details?id=com.banuacoders.siap)

## About

Aplikasi ini dibangun untuk mengatasi permasalahan pencatatan absensi pegawai di lingkungan kantor pemerintahan Kecamatan Balaesang. Pencatatan kehadiran pegawai di kantor pemerintahan Kecamatan Balaesang selama ini masih dilakukan secara manual yaitu dengan memberi paraf pada absensi.

Permasalahan timbul saat sebagian besar pegawai tidak jujur dalam mengisi absen tersebut, ada yang titip ke teman untuk diparaf namanya, ada yang langsung isi absen sampai beberapa hari ke depan, ada yang mengisi absen diluar waktunya, dsb. Dengan adanya sistem ini, diharapkan bisa membantu mengatasi permasalahan-permasalahan yang telah disebutkan.

## License

**SiAP** is open-sourced software licensed under the [GPL v2.0](https://www.gnu.org/licenses/gpl-2.0.html).

## Konfigurasi

*Clone* repository back-end aplikasinya [disini](https://github.com/ryanaidilp/sistem_absensi_pegawai). Buat file **.env** pada root folder aplikasi ini lalu tambahkan variabel berikut

```dotenv
    BASE_URL=BASE URL ONLINE
    LOCAL_URL=LOCAL_URL #Jika kamu ingin menyambungkian ke server di localhost
    ONE_SIGNAL_APP_ID=APP ID UNTUK ONE SIGNAL
    ADMIN_PHONE_NUMBER=Nomor handphone admin server
```

Isikan variabel sesuai dengan konfigurasi anda.

Untuk mendapatkan `ONE_SIGNAL_APP_ID`, buat akun di [One Signal](https://app.onesignal.com) lalu ikuti petunjuk cara untuk mendapatkan `APP_KEY` melalui dokumentasi resmi One Signal.
Pastikan `ONE_SIGNAL_APP_ID` pada aplikasi ini sama dengan yang digunakan di aplikasi [backend](https://github.com/ryanaidilp/sistem_absensi_pegawai)

## Screenshoot

![Splash Screen](https://i.ibb.co/p4n5K3D/splash-screen.gif)![Login Screen](https://i.ibb.co/5TmZYTT/login-screen.gif)![Home Screen](https://i.ibb.co/qyJB11s/home-screen.gif)![Presence Screen](https://i.ibb.co/SVGrL5r/presence-screen.gif)![Presence Process Screen](https://i.ibb.co/6H8YmB9/presence-process-screen.gif)![Employee List Screen](https://i.ibb.co/4dGZXR3/employee-list-screen.gif)![Statistics Screen](https://i.ibb.co/5n2gGzc/statistics-screen.gif)![Statistics Screen](https://i.ibb.co/RYtT7gH/statistics-screen-2.gif)![Absent Permissions Screen](https://i.ibb.co/XSFKdX6/absent-permission-screen.gif)![Outstations Screen](https://i.ibb.co/VqSvMQF/outstation-screen.gif)![Paid Leaves Screen](https://i.ibb.co/zV6m0C8/paid-leave-screen.gif)![Employee Presence Screen](https://i.ibb.co/KXMyMq6/employee-presence-list.gif)![Employee Presence List Screen](https://i.ibb.co/bN1cBnJ/employee-presence-screen-2.gif)![Notifications List & Create Notification Screen](https://i.ibb.co/NtH4pbT/notification-list-screen.gif)
