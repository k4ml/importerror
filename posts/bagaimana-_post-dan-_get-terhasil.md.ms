<!-- 
.. title: Bagaimana $_POST dan $_GET terhasil
.. slug: bagaimana-_post-dan-_get-terhasil
.. date: 2014/03/31 16:23:49
.. tags: php
.. link: 
.. description: 
.. type: text
-->

Dalam PHP, `$_POST` dan `$_GET` adalah 2 bentuk input yang biasa digunakan oleh developer. `$_GET`
mengandungi data daripada *url query string* manakala `$_POST` biasanya mengandungi data yang dihantar
melalui html form. Tapi bagaimanakah data ini terhasil ?

Data untuk `$_GET` dan `$_POST` kedua-duanya dihasilkan dengan memproses HTTP request yang dihantar
oleh client. Secara ringkas, HTTP request adalah dalam bentuk teks dengan format seperti berikut:-

```
GET /index.php?action=list&module=user HTTP/1.1
Content-Type: text/html
User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.
```

Atau:-

```
POST /index.php HTTP/1.1
Content-Type: application/x-www-urlencoded
User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.

username=kamal&address=jb
```

HTTP request ini terbahagi kepada 3 bahagian iaitu Request line, Headers dan Body. Untuk GET request
bagaimana pun, tiada bahagian Body yang dihantar dalam request tersebut. Data ini dihantar dalam bentuk
teks ke *socket* di mana web server yang mengendalikan request ini *listen*. PHP biasanya menggunakan
Apache sebagai web server dan apache biasanya akan *listen* pada port 80.

Setelah diterima oleh *web server*, data tersebut akan di*pass* ke PHP yang seterusnya akan memproses
data tersebut (parsing) untuk dimasukkan ke dalam superglobal variables seperti `$_POST`, `$_GET` dan
lain-lain. Bagaimana proses tersebut dilakukan adalah adalah agak kompleks dengan [beberapa lapis kod C][1]
tetapi secara asasnya adalah seperti berikut:-

* $_GET dihasilkan daripada Request line - GET /index.php?action=list&module=user HTTP/1.1
    - Secara mudahnya kita boleh split kepada 3 bahagian - ['GET', '/index.php?action=list&module=user', 'HTTP/1.1']
    - Kemudian kita boleh parse bahagian kedua berdasarkan simbol '?' dan '&' untuk mendapatkan data yang
      dikehendaki.

* $_POST dihasilkan daripada Body jadi kita boleh terus `split` data tersebut berdasarkan simbol '&'.

Ini adalah penerangan dalam bentuk yang amat ringkas bagaimana input untuk PHP dihasilkan. Saya akan cuba
kembangkan topik ini dalam tulisan akan datang.

[1]:http://stackoverflow.com/questions/16422605/how-exactly-is-php-creating-superglobal-post-get-cookie-and-request
