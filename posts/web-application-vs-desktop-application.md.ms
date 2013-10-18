<!-- 
.. link: 
.. description: 
.. tags: draft, web, desktop
.. date: 2013/10/18 18:42:26
.. title: Aplikasi Web vs Aplikasi Desktop
.. slug: aplikasi-web-vs-aplikasi-desktop
-->

Mereka yang baru bermula dalam pembangunan aplikasi web kerap kali keliru akan 
konsep dalam aplikasi web dan menganggap ianya sama dengan aplikasi desktop. Ini menyebabkan mereka mengharapkan dapat melakukan perkara yang sama seperti 
mana dalam aplikasi desktop. Antara contoh soalan popular yang seringkali 
ditanya adalah bagaimana untuk mencetak daripada aplikasi web mereka.

Pertama sekali mari kita lihat diagram ringkas susun atur sebuah aplikasi 
desktop:-

<img src="http://i.imgur.com/LWG9VlQl.jpg"></img>

Dalam rajah di atas, kita dapat lihat bagaimana aplikasi yang kita bangunkan 
dapat berhubung terus dengan _hardware_ melalui OS (_Operating System_). Ini 
membolehkan aplikasi tersebut untuk mencapai dan menggunakan peranti-peranti 
lain seperti _printer_ dan _webcam_ yang bersambung dengan komputer tersebut. Seterusnya, kita lihat pula rajah susunan sebuah aplikasi web:-

<img src="http://i.imgur.com/eOt8gRzl.jpg"></img>

Di atas dapat diperhatikan bagaimana aplikasi tidak lagi dijalankan secara 
terus pada _computer_ sebagaimana dalam aplikasi desktop. Sebaliknya ia hanya 
dicapai melalui perantaraan _browser_. Ini menyebabkan capaian aplikasi web 
kepada fungsi-fungsi komputer hanya terhad kepada apa yang _browser_ benarkan. Dan sememangya atas tujuan keselamatan, _browser_ akan menghadkan capaian 
aplikasi kepada _hardware_ seperti _printer_ dan _webcam_. Ini antara perbezaan penting yang harus difahami apabila membangunkan sebuah aplikasi web.

__Perhatian__: Rajah di atas menunjukkan susunan LOGIKAL manakala secara FIZIKAL boleh sahaja sebuah aplikasi web itu dijalankan dalam komputer yang sama. Walaubagaimana pun kekangan asal sebuah aplikasi web tetap sama. 
