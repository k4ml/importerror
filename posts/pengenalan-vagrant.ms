<!-- 
.. link: 
.. description: 
.. tags: 
.. date: 2013/09/29 22:43:02
.. title: Pengenalan Vagrant
.. slug: pengenalan-vagrant
-->

Tools untuk membina _virtual machine_ dengan cepat. _Virtual Machine_ yang 
dibina adalah berasaskan VirtualBox. VirtualBox adalah sebuah mesin maya, 
seperti komputer fizikal atau laptop yang anda biasa guna. Anda boleh membina 
sejumlah mesin maya dan memasang pelbagai jenis OS seperti Ubuntu Linux, 
Windown 7 dan sebagainya.

## Kenapa guna _Virtual Machine_ ?
Developer biasanya melakukan kerja-kerja pembangunan di komputer desktop atau 
laptop masing-masing. Setelah siap, aplikasi tersebut akan di'deploy' ke server 
khas yang akan dicapai oleh pengguna sistem tersebut. Ini adalah senario 
tipikal dalam pembangunan laman web atau aplikasi web. Konfigurasi desktop atau 
laptop yang digunakan untuk _development_ biasanya berbeza dengan server yang 
digunakan untuk _deployment_. Ini menyebabkan pelbagai isu yang tidak timbul 
semasa proses _development_ atau _testing_ muncul apabila ia cuba dijalankan di 
server. Keadaan ini amat membazirkan masa dan antara sebab _release_ sesuatu 
sistem terpaksa dilengahkan. 

Mengunakan _virtual machine_, _developer_ dapat membina server yang sama 
konfigurasi dengan server sebenar dalam masa yang singkat. Ini membolehkan 
mereka menguji aplikasi yang dibangunkan dalam persekitaran sebenar. _Virtual 
Machine_ yang dibina itu juga boleh dikongsi dengan _developer_ lain menjadikan 
proses testing dalam sesuatu _development team_ semakin pantas dan tidak 
membebankan.

## Install
Ada beberapa pilihan bergantung OS yang anda gunakan seperti msi installer 
untuk Windows, package .deb untuk Debian/Ubuntu dan .dmg untuk pengguna MacOS.

...

## Contoh Penggunaan (Use case)
Saya hendak membina sebuah _base machine_ dengan kriteria berikut:-

* Menggunakan OS Ubuntu Precise 32bit.
* Semua package dikemaskini ke versi paling terkini.
* Package seperti postgresql, mysql dan apache2 telah siap di'install'.

Bina machine pertama:-
    
```console
vagrant box add precise32 http://files.vagrantup.com/precise32.box
vagrant init precise32
vagrant up
vagrant ssh
```

Kini anda sudah berada dalam machine precise32. Update Ubuntu:-

```console
sudo apt-get update
sudo apt-get upgrade
```

Install package yang dikehendaki:-

```console
sudo apt-get build-essential apache2 postgresql mysql-server
exit
```

Kini anda berada dalam mesin sebenar (fizikal). Kita akan buat copy
untuk mesin yang pertama. Buat satu file konfigurasi asas untuk mesin yang
kita nak pakejkan ini. Simpan sebagai Vagrantfile.pkg:-

```ruby
Vagrant::Config.run do |config|
    # Forward apache
    config.vm.forward_port 80, 8080
end
```

Dalam konfigurasi di atas kita membuat _port forwarding_ dari port 8080 di
mesin fizikal ke port 80 di mesin maya yang bakal kita bina. Ini membolehkan
kita akses apache di mesin maya menggunakan url seperti http://localhost:8080/
daripada laptop atau desktop kita (mesin fizikal). Arahan berikutnya akan
melaksanakan proses _packaging_.

```console
vagrant package --vagrantfile Vagrantfile.pkg
```

Setelah siap, anda akan dapati satu fail bernama `package.box`. Fail ini boleh
dikongsikan dengan rakan-rakan yang lain dan mereka akan mendapat sebuah mesin
maya berasaskan Ubuntu Precise 32bit yang telah siap dipasang dengan apache2,
mysql dan postgresql.

Untuk mula menggunakan box yang baru kita hasilkan tadi, gunakan arahan berikut:-

```console
vagrant box add precise32-base package.box
vagrant box list
```

Anda akan mendapat output seperti berikut:-

```console
lucid32
precise32-base
```

Bina virtual machine baru berasaskan `precise32-base`:-

```console
vagrant init precise32-base
```

Anda akan mendapat output seperti berikut:-

```console
    A `Vagrantfile` has been placed in this directory. You are now
    ready to `vagrant up` your first virtual environment! Please read
    the comments in the Vagrantfile as well as documentation on
    `vagrantup.com` for more information on using Vagrant.
```

## Rujukan
http://vagrantup.com/
