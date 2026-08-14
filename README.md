# Dashboard Assessment QRIS Wilayah Jawa — Website

Versi website dari aplikasi Dashboard Assessment QRIS, dibangun dengan pola yang sama
seperti OSUKA: **HTML/JS statis + Supabase (live data) + GitHub Pages (hosting)**.

Isi folder ini:

| File | Fungsi |
|---|---|
| `index.html` | Website utuh (1 file, HTML+CSS+JS) — dashboard 7 section + halaman Login/Signup/Reset Password |
| `schema.sql` | Skema tabel Supabase + seed data hasil transformasi `Data_QRIS_2026.xlsx` |
| `auth_setup.sql` | Trigger pembatas domain email `@bi.go.id` + pengetatan RLS ke "hanya user login" |
| `README.md` | Panduan ini |

---

## 1. Membuat Project Supabase

1. Buka [supabase.com](https://supabase.com) → login → **New project**.
   *(Bisa juga memakai project Supabase OSUKA yang sudah ada, asal Bapak buat tabel baru
   dengan nama yang tidak bentrok — semua tabel di `schema.sql` sudah diberi prefix `qris_`
   agar aman berdampingan dengan tabel `MD_`/`TRX_` milik OSUKA.)*
2. Setelah project dibuat, buka menu **SQL Editor** → **New query**.
3. Salin seluruh isi `schema.sql` → paste → **Run**.
   Ini akan membuat 6 tabel (`qris_rekap_bulanan`, `qris_target`, `qris_strategi`,
   `qris_rekomendasi`, `qris_key_findings`, `qris_insight`) sekaligus mengisi data awal
   (108 baris data transaksi + 18 baris target dummy + konten strategi/rekomendasi).
4. Cek di menu **Table Editor** — pastikan ke-6 tabel muncul berisi data.

## 2. Mengambil Kredensial API

1. Di Supabase, buka **Project Settings** (ikon gerigi) → **API**.
2. Salin dua nilai berikut:
   - **Project URL** (bentuknya `https://xxxxxxxx.supabase.co`)
   - **anon public key** (kunci panjang di bagian "Project API keys")
3. Buka `index.html` dengan text editor, cari baris berikut (di bagian bawah file, dalam tag `<script>`):

   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
   ```

   Ganti dengan nilai Project URL dan anon public key milik Bapak. Simpan file.

> **Catatan keamanan:** anon public key **aman** ditaruh di file frontend (memang didesain
> untuk itu) selama Row Level Security aktif — `schema.sql` sudah mengaktifkan RLS dengan
> policy *read-only* untuk publik. Jangan pernah menaruh *service role key* di file ini.

## 3. Uji Coba Lokal

Buka `index.html` langsung dua kali klik di browser, atau jalankan local server sederhana:

```bash
npx serve .
# atau
python3 -m http.server 8080
```

Jika berhasil, badge hijau "Terhubung ke Supabase — data live" akan muncul sebentar di atas,
lalu seluruh 7 section terisi data.

## 4. Mengganti Target Dummy dengan Target Resmi

Buka **Table Editor** → tabel `qris_target` di Supabase → edit langsung kolom `target_nilai`
per baris (provinsi × indikator), atau jalankan `UPDATE` via SQL Editor. Setelah disimpan,
refresh website — tabel capaian & status akan otomatis menyesuaikan (tidak perlu ubah kode).

## 5. Mengaktifkan Login, Signup & Reset Password (khusus domain @bi.go.id)

Website ini sekarang meminta login sebelum menampilkan dashboard. Sebelum dipakai, jalankan
setup berikut:

1. Buka **SQL Editor** → **New query** → salin seluruh isi `auth_setup.sql` → **Run**.
   Ini akan:
   - Memasang **trigger database** yang menolak pendaftaran dengan email selain `@bi.go.id`
     — ini penegakan yang sesungguhnya (bukan sekadar validasi tampilan di JS, yang selalu
     bisa dilewati orang yang cukup paham teknis).
   - Mengganti policy RLS tabel `qris_*` dari "bisa dibaca siapa saja" menjadi
     "hanya bisa dibaca user yang sudah login" — sejalan dengan tujuan menambahkan halaman auth.
2. Buka **Authentication → URL Configuration** di Supabase:
   - **Site URL**: isi dengan alamat website production nanti (mis.
     `https://<username-github>.github.io/qris-dashboard-portal/`).
   - **Redirect URLs**: tambahkan URL yang sama (dan `http://localhost:8080/` bila masih
     uji coba lokal). Ini **wajib** agar tautan di email "Lupa Password" mengarah ke halaman
     yang tepat, bukan ke domain default Supabase.
3. Buka **Authentication → Providers → Email**: pastikan **"Confirm email"** sesuai kebutuhan —
   ON (disarankan) berarti user wajib klik link verifikasi di email dulu sebelum bisa login;
   OFF berarti user langsung punya sesi aktif begitu daftar (auto-login setelah signup).
4. Coba alur lengkap: buka website → **Daftar** dengan email `@bi.go.id` → cek email verifikasi
   (jika Confirm Email ON) → **Masuk** → dashboard tampil. Coba juga **Lupa Kata Sandi** untuk
   memastikan email reset terkirim dan tautannya membuka form "Atur Kata Sandi Baru".
5. Uji penolakan domain: coba daftar dengan email selain `@bi.go.id` (mis. Gmail) — harus
   ditolak baik oleh pesan di form maupun (jika dicoba paksa lewat API) oleh trigger database.

> **Akun pertama:** karena signup terbuka untuk siapa saja dengan email `@bi.go.id`, tidak ada
> mekanisme approval berjenjang di versi ini — siapa pun dengan email dinas BI yang valid bisa
> langsung membuat akun dan melihat dashboard begitu proses verifikasi email selesai. Kalau
> Bapak perlu approval manual sebelum akun aktif, itu bisa ditambahkan di pengembangan lanjutan
> (lihat bagian 7).

## 6. Deploy ke GitHub Pages (pola sama seperti OSUKA)

1. Buat repository baru di GitHub, misalnya `qris-dashboard-portal`.
2. Upload `index.html` ke root repository (`schema.sql`, `auth_setup.sql`, `README.md` boleh
   ikut untuk dokumentasi, tidak wajib untuk hosting).
3. Buka **Settings** → **Pages** → Source: pilih branch `main`, folder `/ (root)` → **Save**.
4. Tunggu 1–2 menit, website akan aktif di:
   `https://<username-github>.github.io/qris-dashboard-portal/`
5. **Setelah URL final diketahui**, kembali ke Supabase **Authentication → URL Configuration**
   dan pastikan Site URL/Redirect URLs (langkah 5.2 di atas) memakai URL GitHub Pages ini.
6. *(Opsional)* Sematkan link tersebut sebagai tab di Microsoft Teams channel Unit PUR, atau
   embed via iframe di halaman SharePoint (Web Part "Embed").

## 7. Update Data Bulanan

Setiap periode baru:

1. Siapkan rekap Excel bulan berjalan (format sama seperti `Data_QRIS_2026.xlsx`).
2. Tambahkan baris baru ke tabel `qris_rekap_bulanan` via Table Editor Supabase, atau
   generate `INSERT` statement baru (pola sama seperti di `schema.sql`) dan jalankan di SQL Editor.
3. Website otomatis menampilkan data terbaru begitu di-refresh — tidak perlu deploy ulang.

## 8. Pengembangan Lanjutan

- **Data Merchant (section 5 "Deep Dive")**: saat ini section ini menampilkan placeholder
  karena `Data_QRIS_2026.xlsx` belum memuat data merchant. Untuk mengaktifkannya, buat tabel
  baru `qris_merchant` (kolom: `provinsi`, `periode`, `merchant_dormant_dihapus`,
  `merchant_existing`, `akuisisi_per_bulan`) lalu tambahkan blok fetch + render di `index.html`
  mengikuti pola tabel lain.
- **Breakdown per KPw** (mockup asli menampilkan 14 KPw termasuk kota seperti Solo, Tegal,
  Kediri — lebih granular dari 6 provinsi): tambahkan kolom `kpw` di `qris_rekap_bulanan`
  jika data granular per-kota tersedia di masa depan.
- **Approval akun manual**: tambahkan kolom `status` (mis. `pending`/`approved`) di tabel
  `public.profiles` yang disinkron dari `auth.users`, dan cek status ini saat login — akun baru
  tidak otomatis bisa lihat dashboard sampai di-approve admin lewat Table Editor.
- **Role admin vs viewer**: saat ini semua user `@bi.go.id` yang login setara (read-only
  dashboard). Untuk peran admin yang bisa edit data langsung dari website (bukan lewat Supabase
  Table Editor), tambahkan kolom `role` di tabel profil + UI form edit, mengikuti pola yang
  sudah pernah dibangun di OSUKA.
- **Grafik tren bulanan**: setelah data 12 bulan penuh tersedia, tambahkan Chart.js untuk
  visualisasi tren User/Nominal/Volume per bulan.
