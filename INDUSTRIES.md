# Industri Indonesia: catatan implementasi dan validasi

Status 31 Oktober 2026: implementasi lokal, belum diuji bermain langsung. Target adalah Transport Fever 2 **35924**, sesuai log game terpasang dan build stabil teratas pada [release notes resmi](https://wiki.transportfever2.com/doku.php?id=releasenotes). Tidak ditujukan untuk Transport Fever 3.

## Cara memakai

Gunakan Indonesia Fever sebagai **pengganti** sistem industri Yeol, bukan memuat keduanya bersamaan. Aset industri yang dibutuhkan telah disertakan atau mengacu ke game utama. Workshop Yeol dan Legacy Vehicle Pack tidak diperlukan untuk referensi aset industri yang diperiksa.

Mulai map baru dengan industri yang dihasilkan setelah mod aktif. Jangan menambahkan overhaul ini ke save vanilla atau Yeol lalu menganggap rantai/kebutuhan kotanya otomatis dapat dikonversi. Untuk melanjutkan save pengembangan Indonesia Fever sebelumnya, simpan salinan save terlebih dahulu; layout tidak dibangun ulang otomatis, dan penerapan resep pada bangunan lama perlu diuji di game. Perubahan tahun ketersediaan mengatur penempatan industri baru, bukan menghapus bangunan lama.

Kemunculan kota industri **nonaktif secara bawaan**. Jika diaktifkan, maksimal tiga kota kecil baru, minimal 2 km dari kota yang ada, di dekat pabrik yang telah berkembang. Kebutuhan kota diperbarui bertahap, maksimal 20 kota per tick, dengan histeresis populasi 25 agar tidak berganti terus di ambang batas. Kota kecil tetap menerima barang komersial dan industri.

## Era dan rantai utama

| Mulai | Rantai / perubahan | Pertimbangan |
| --- | --- | --- |
| 1850 | Padi, peternakan rakyat, perikanan, serat, tekstil, kayu, bata, perkakas, pos | Produksi pangan bisa memakai padi saja, padi dengan susu, daging, atau ikan; susu tidak diwajibkan untuk semua wilayah. |
| 1850 | Timah → ekspor | Pengalengan belum muncul; ekspor memberi tujuan bagi timah awal. |
| 1885 | Minyak mentah → ekspor; kilang dari 1900 | Sumur awal tidak menunggu kilang untuk memiliki pembeli. |
| 1900 | Pertanian khusus, mesin, distribusi industri mekanis | Peternakan dan tanaman pakan menggantikan pertanian campuran dalam penempatan baru dari 1901. |
| 1910 | Semen, beton, kaca, bahan bangunan modern, mobil, pengalengan | Semen memakai batu kapur + tanah liat + batubara. Pengalengan memakai ikan/daging + baja + timah. |
| 1911 | Perkebunan/pengolahan awal sawit → CPO → minyak pangan | Bukan perkebunan komersial pada 1850. |
| 1935 | Bauksit → ekspor | Industri aluminium domestik belum tersedia. |
| 1950 | Tembaga, plastik, serat sintetis, elektronik, peralatan rumah tangga, daur ulang | Tahun kelompok teknologi merupakan abstraksi gameplay, bukan klaim tanggal pendirian semua pabrik Indonesia. |
| 1978 | Bijih nikel → produk antara nikel → permesinan | Resep mesin baja + nikel menjadi alternatif baja + minyak pelumas. |
| 1980 | Komputer, barang TI | Rantai elektronik sudah tersedia sebelumnya. |
| 1982 | Aluminium → kaleng aluminium | Alternatif kaleng baja berlapis timah; tidak memutus rantai pengalengan lama. |
| 2000 | Perangkat elektronik modern | Kebutuhan muncul pada kota yang cukup besar. |
| 2006 | CPO → biodiesel | Mengikuti awal pemasaran biodiesel di Indonesia. |
| 2020 | Pengolahan akhir residu | Tujuan pembuangan, bukan mengubah abu/residu menjadi bahan bakar cair. |

Serat alami, bata tradisional, dan TPA tetap bisa ditempatkan setelah era modern agar tidak memutus suplai/pembuangan. Pasir dan batu kapur baru muncul pada 1910 bersama konsumennya. Sistem ini tidak mencakup semua komoditas sejarah Indonesia; kopi, gula, teh dan tembakau belum menjadi rantai tersendiri.

Rujukan sejarah: [sawit komersial 1911, Ditjenbun](https://ditjenbun.pertanian.go.id/minyak-kelapa-sawit-dalam-persaingan-minyak-nabati-global/), [Semen Padang 1910](https://www.semenpadang.co.id/id/sejarah), [perminyakan Indonesia, repositori DPR](https://repositori.dpr.go.id/id/eprint/677/1/120.SEJARAH%20PERMINYAKAN%20DI%20INDONESIA.pdf), [produksi komersial nikel 1978, laporan Vale 2013](https://www.vale.com/documents/44618/1371772/Annual-Report-2013.pdf/43819966-3c10-0f0f-846e-8a833a23e60a?download=false&t=1771907131614&version=1.1), [operasi INALUM 1982, ANTARA](https://sumut.antaranews.com/berita/367335/45-tahun-hadir-untuk-sumut-inalum-resmikan-gedung-perkantoran-8-lantai-pertama), [spesifikasi biodiesel 2006, ESDM](https://jdih.esdm.go.id/dokumen/view?id=438).

## Keseimbangan

Takaran di bawah adalah **unit gameplay**, bukan neraca massa pabrik dalam ton. Kapasitas aturan berarti jumlah siklus produksi tahunan pada tingkat tersebut; hasil aktual juga bergantung pada suplai, permintaan dan layanan angkutan.

| Industri | Resep per siklus | Kapasitas dasar |
| --- | --- | --- |
| Pengolahan pangan | 2 padi ATAU 1 padi + 1 susu ATAU 2 daging ATAU 2 ikan → 2 pangan | 100 |
| Sawit terpadu | tanpa input angkutan → 1 CPO | 100 |
| Minyak pangan | 1 CPO → 1 pangan | 100 |
| Biodiesel | 2 CPO → 1 bahan bakar | 100 |
| Timah | 1 bijih timah + 1 batubara → 2 timah | 200 |
| Nikel | 2 bijih nikel + 1 batubara → 1 nikel | 100 |
| Semen | 2 kapur + 1 tanah liat + 1 batubara → 2 semen | 100 |
| Mobil | 2 baja + ban + kaca + mesin + tekstil → 1 mobil | 50 |
| Daur ulang | 8 sampah → baja + kertas + plastik + kaca + 2 residu | 100 |
| Insinerator | 4 sampah → 1 residu | 100 |
| Pengolahan residu | 4 residu → pembuangan akhir | 50 |

Kapasitas mobil diturunkan dari 400 agar satu perakit tidak menuntut rantai komponen beberapa kali lebih besar dari pemasok dasarnya. Minyak pangan tidak menggandakan CPO; biodiesel membutuhkan lebih banyak input daripada bahan bakar konvensional. Daur ulang mempunyai kehilangan material dan residu, sehingga bukan sumber bahan baku gratis tanpa batas. Limbah akhir selalu memiliki tujuan yang tersedia.

Biaya penempatan untuk industri mod: `750000 + 7500 × kapasitas`, dikalikan 1,5 untuk sumber tanpa input. Biaya bongkar 10%, pemeliharaan 0,01% dari biaya tersebut; biaya bukan pendapatan pemain. Ini nilai awal untuk playtest, bukan hasil pengukuran profitabilitas permainan. Input yang tidak mempunyai tumpukan visual pada layout warisan diberi kapasitas gudang internal dua kali kebutuhan produksi tahunan. Kapasitas kendaraan tidak ditambah: komoditas baru adalah pilihan muatan dalam kompartemen yang sama.

Penyederhanaan penting: perkebunan sawit digabung dengan pengolahan awal CPO; FOOD mencakup beras olahan dan minyak pangan; energi aluminium memakai FUEL sebagai proksi untuk pemurnian/kelistrikan; NICKEL mencakup produk antara metalurgi. Model bangunan dan sebagian visual kargo memakai aset Yeol/game utama, belum arsitektur pabrik Indonesia yang dibuat khusus. Jangan membaca jadwal dan resep ini sebagai simulasi teknis lengkap.

## Kompatibilitas dan perlindungan save

- Mendukung format kendaraan lama `compartments` dan format modern `compartmentsList`, termasuk `cargoBay`, `toHide` dan kapasitas asli. Muatan campuran tetap dipertahankan. Modifikasi bersifat idempoten.
- Callback harga/penyimpanan industri dibatasi pada nama sumber daya industri Indonesia Fever. Mod lain yang menggunakan **nama sumber daya sama** tetap berbenturan; daftar nama tidak bisa membedakan sumber daya yang saling menimpa.
- Tidak mengubah RNG global atau parameter bangunan milik engine. Pos/sampah stabil untuk seed bangunan yang sama.
- Tidak ada pembaruan massal industri, penghapusan seed, penghapusan save, atau auto-convert save vanilla.
- Deteksi Town Tuning yang diwarisi dipertahankan: pengelolaan kebutuhan kota dimatikan saat parameter `fasterTownDevelopInterval` ditemukan. Kombinasi ini belum diuji dan dapat memerlukan penyesuaian kebutuhan kargo. Mod overhaul kargo/industri lain bukan kombinasi yang dijamin kompatibel.
- Tiga model dekorasi/kargo yang memakai mesh kendaraan lama dipindahkan ke referensi model `_v2` game utama. Material `Pallet.mtl` memakai kapitalisasi tepat untuk Linux.
- Tekstur tanah kilang tingkat 3–4 memakai permukaan tingkat 2 game utama sebagai proksi; periksa kesesuaian visualnya saat playtest.

Dokumentasi teknis acuan: [construction types](https://wiki.transportfever2.com/doku.php?id=modding:constructiontypes), [vehicle basics](https://wiki.transportfever2.com/doku.php?id=modding:vehiclebasics), [API town cargo needs](https://wiki.transportfever2.com/api/modules/api.type.html). Basis asal: [Yeol's Senseless Industries 2.21a](https://steamcommunity.com/sharedfiles/filedetails/?id=2799634962). Kredit asal dipertahankan; belum dipublikasikan ke Workshop.

## Pemeriksaan yang dapat diulang

```sh
python3 tools/check_industries.py
# Instalasi Steam lain:
python3 tools/check_industries.py --game-res '/path/Transport Fever 2/res'
```

Memerlukan Python 3 dan shared library Lua 5.3/5.4. Pemeriksaan membaca arsip/aset game tanpa mengekstrak atau mengubahnya. Implementasi `industryutil` dan `constructionutil` dari game dipakai langsung; iterator/seed bawaan engine disediakan oleh fixture. Native engine, GPU, pathfinding dan ekonomi berjalan tidak disimulasikan.

Hasil lokal: 16 kelompok pemeriksaan lulus; 66 industri, 191 tingkat, 62 kargo; 6.355 referensi aset ditemukan. Pemeriksaan mencakup sintaks, resep, kapasitas penyimpanan, tekstur tanah, lokalisasi en/id, jalur pasokan dan tujuan setiap tahun 1850–2030, kompartemen kendaraan, kebutuhan kota, kegagalan command, save/load skrip, serta batas kota industri.

## Gerbang playtest yang masih terbuka

- [ ] Map baru pada 1850, 1900, 1910, 1950, 1978, 1982, 2000 dan 2026, hanya Indonesia Fever plus mod resmi yang diperlukan oleh konfigurasi game.
- [ ] Muat kota/industri, naikkan setiap tingkat, cek jalan akses, material, visual kargo, suara dan error di stdout.
- [ ] Jalankan jalur pangan–tekstil–komersial dan perkakas–bangunan–industri; pastikan shipment/transport menggiring pertumbuhan industri.
- [ ] Hubungkan timah ke ekspor dan kaleng; nikel ke mesin; sawit ke pangan dan biodiesel; kelola sampah hingga pembuangan akhir.
- [ ] Bandingkan kapasitas, utilisasi, biaya angkutan dan keuntungan di difficulty Medium selama setidaknya lima tahun permainan per era. Ukur apakah jalur sawit/ekspor mendominasi atau justru tidak layak.
- [ ] Simpan/muat ulang dan uji kota kecil/besar, ambang kebutuhan, kendaraan lama/modern, serta opsi kota industri.
- [ ] Uji salinan save pengembangan lama secara terpisah; jangan menganggap migrasi aman hanya dari fixture Lua.

Belum ada bukti playtest native. Kompatibilitas final dan keseimbangan ekonomi di permainan baru dapat dinyatakan setelah gerbang di atas lulus.
