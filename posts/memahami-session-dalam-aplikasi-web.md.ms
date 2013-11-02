<!-- 
.. link: 
.. description: 
.. tags: php, session, http
.. date: 2013/10/28 18:36:43
.. title: Memahami Session dalam Aplikasi Web
.. slug: memahami-session-dalam-aplikasi-web
-->

_Session_ dalam aplikasi web adalah untuk mengatasi masalah yang berkaitan dengan sifat _stateless_ dalam protokol HTTP. Contohnya apabila kita melayari satu laman web, dan membuka laman utama dan kemudian laman yang kedua, server tidak akan dapat mengenalpasti orang yang mengakses laman kedua adalah orang yang sama mengakses laman pertama tadi. Ini menyebabkan masalah apabila kita ingin membangunkan aplikasi di mana sebahagian daripada laman kita adalah untuk pengguna tertentu sahaja. Ataupun aplikasi yang perlu menyimpan data apa yang user lakukan pada laman pertama, dan seterusnya memaparkan di laman yang kedua atau seterusnya. Contohnya sebuah laman _e-commerce_ yang mempunyai fungsi _shopping cart_. Di laman pertama, pengguna akan _add_ barangan yang ingin dibeli ke dalam _cart_. Bila pengguna membuka laman lain di website tersebut, kita mungkin ingin memaparkan kepada pengguna apa yang telah mereka masukkan ke dalam _cart_.

[Protokol HTTP][1] mempunyai konsep _cookie_, di mana apabila pengguna mengakses laman web kita, kita boleh 'tanam' data yang akan disimpan dalam komputer pengguna. Setiap kali mereka mengakses laman kita, data tersebut akan dihantar sekali. Ini membolehkan kita mengenalpasti pengguna ini telah pun melawat laman kita sebelum ini. Jadi secara teori, kita boleh menggunakan _cookie_ ini untuk menyelesaikan masalah berkaitan _shopping cart_ sebelum ini. Kita boleh simpan barang yang pengguna masukkan ke dalam _cart_ di dalam _cookie_. _Cookie_ bagaimana pun mempunyai beberapa masalah seperti saiz yang terhad (4K) dan juga pengguna boleh mengubah data yang disimpan di dalam _cookie_ sesuka hati mereka. Ada cara untuk mengelakkan data dalam _cookie_ diubah namun ia di luar skop artikel ini.

Jadi satu teknik baru untuk menyimpan data pengguna digunakan - ia dipanggil _session_. Ia masih menggunakan _cookie_ tetapi tidak menyimpan kesemua data ke dalam cookie. Sebaliknya apa yang disimpan dalam _cookie_ hanyalah rujukan (reference / pointer) kepada data sebenar yang di simpan di bahagian server. Apa yang disimpan dalam _cookie_ hanyalah ID unik yang boleh digunakan untuk _query_ _data store_ di server bagi mendapatkan data sebenar. _data store_ ini boleh jadi berbentuk _file_ (default storage PHP session), row dalam database dan sebagainya. Dalam tulisan ini, saya cuba menunjukkan konsep asas implementasi _session_ menggunakan bahasa pengaturcaraan PHP.

Berikut adalah kod utama yang akan _implement_ _session_ bagi web aplikasi kita. Kod ini boleh disimpan dalam fail bernama `mysession.php`:-

```php
<?php
/* This is for learning purpose only - just to show how session in theory being 
implemented. For real session usage, use the session provided by your web framework.
*/

$HERE = realpath(dirname(__FILE__));
$SESSION_CLOSED = False;

function end_session() {
    if (!$GLOBALS['SESSION_CLOSED']) {
        $session_file = $GLOBALS['HERE'] . '/' . $GLOBALS['_MYSESSID'] . '.session';
        file_put_contents($session_file, serialize($GLOBALS['_MYSESSION']));
        $GLOBALS['SESSION_CLOSED'] = True;
    }
}

function start_session() {
    if (array_key_exists('mysessid', $_COOKIE)) {
        $mysessid = $_COOKIE['mysessid'];
        $session_file = $GLOBALS['HERE'] . '/' . $mysessid . '.session';
        if (file_exists($session_file)) {
            $GLOBALS['_MYSESSION'] = unserialize(file_get_contents($session_file));
        }
        else {
            $GLOBALS['_MYSESSION'] = array();
        }
    }
    else {
        $mysessid = uniqid('MYSESSID');
        setcookie('mysessid', $mysessid);
        $GLOBALS['_MYSESSION'] = array();
    }
    $GLOBALS['_MYSESSID'] = $mysessid;
    register_shutdown_function('end_session');
}
```

Dan bagi setiap _page_ yang ingin menggunakan fungsi _session_ ini, contohnya `index.php`:-

```php
<?php

include 'mysession.php';

start_session();
print_r($_MYSESSION);
$_MYSESSION['name'] = 'kamal';
```

Page yang kedua, `index2.php`:-

```php
<?php

include 'mysession.php';

start_session();
print_r($_MYSESSION);
$_MYSESSION['on_index2'] = True;
```

Dalam contoh di atas, apabila pengguna melawat `index2.php`, data dalam `$_MYSESSION['name']` yang disetkan pada laman pertama akan dipaparkan. Dalam function `start_session()`, apa yang berlaku adalah kita check jika pengguna mempunyai nilai cookie `mysessid`, jika ada kita akan cuba load data yang disimpan dalam _file_ `$mysessid.session` ke dalam _variable_ global `$_MYSESSION`. Manakala setiap kali _script_ tersebut berakhir, kita akan simpan balik data dalam variable `$_MYSESSION` ke dalam _file_ `$mysessid.session`. Ini adalah konsep asas bagaimana _session_ berfungsi. Di sini kita menyimpan data di dalam _file_ namun boleh saja data tersebut disimpan di dalam database table dengan `mysessid` berfungsi sebagai _primary key_ bagi rekod tersebut.

[1]:http://tools.ietf.org/html/rfc2616
