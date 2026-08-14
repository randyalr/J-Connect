-- ============================================================
-- Skema & Seed Data: Dashboard Assessment QRIS Wilayah Jawa
-- Jalankan seluruh script ini di Supabase SQL Editor (Project > SQL Editor > New query)
-- ============================================================

-- 1) Tabel data transaksi bulanan (format long: 1 baris = 1 kombinasi provinsi-bulan-indikator)
create table if not exists qris_rekap_bulanan (
  id bigint generated always as identity primary key,
  provinsi text not null,
  tahun int not null,
  bulan text not null,
  bulan_num int not null,
  indikator text not null check (indikator in ('User','Nominal','Volume')),
  nilai numeric not null,
  created_at timestamptz default now()
);

-- 2) Tabel target per provinsi & indikator (dasar hitung % capaian)
create table if not exists qris_target (
  id bigint generated always as identity primary key,
  provinsi text not null,
  tahun int not null,
  indikator text not null check (indikator in ('User','Nominal','Volume')),
  target_nilai numeric not null,
  keterangan text,
  updated_at timestamptz default now()
);

-- 3) Tabel konten galeri Strategi Semester II
create table if not exists qris_strategi (
  id bigint generated always as identity primary key,
  title text not null,
  deskripsi text not null,
  urutan int not null,
  ikon text
);

-- 4) Tabel konten galeri Executive Recommendation
create table if not exists qris_rekomendasi (
  id bigint generated always as identity primary key,
  title text not null,
  deskripsi text not null,
  urutan int not null,
  ikon text
);

-- 5) Tabel key findings (Best Practice / Monitoring) - section 4 mockup
create table if not exists qris_key_findings (
  id bigint generated always as identity primary key,
  kategori text not null check (kategori in ('Best Practice','Monitoring')),
  provinsi text not null,
  urutan int not null
);

-- 6) Tabel insight eksekutif (kutipan banner bawah)
create table if not exists qris_insight (
  id bigint generated always as identity primary key,
  isi text not null,
  aktif boolean default true
);

-- Row Level Security: aktifkan + izinkan SELECT publik (read-only untuk website),
-- INSERT/UPDATE/DELETE tetap perlu service role / login admin.
alter table qris_rekap_bulanan enable row level security;
create policy "Public read qris_rekap_bulanan" on qris_rekap_bulanan for select using (true);
alter table qris_target enable row level security;
create policy "Public read qris_target" on qris_target for select using (true);
alter table qris_strategi enable row level security;
create policy "Public read qris_strategi" on qris_strategi for select using (true);
alter table qris_rekomendasi enable row level security;
create policy "Public read qris_rekomendasi" on qris_rekomendasi for select using (true);
alter table qris_key_findings enable row level security;
create policy "Public read qris_key_findings" on qris_key_findings for select using (true);
alter table qris_insight enable row level security;
create policy "Public read qris_insight" on qris_insight for select using (true);

-- ============================================================
-- SEED DATA — hasil transformasi Data_QRIS_2026.xlsx (108 baris)
-- ============================================================
truncate table qris_rekap_bulanan restart identity;
insert into qris_rekap_bulanan (provinsi, tahun, bulan, bulan_num, indikator, nilai) values
('DI Yogyakarta',2026,'Januari',1,'User',1019592.0),
('DI Yogyakarta',2026,'Februari',2,'User',1036962.0),
('DI Yogyakarta',2026,'Maret',3,'User',1055863.0),
('DI Yogyakarta',2026,'April',4,'User',1081475.0),
('DI Yogyakarta',2026,'Mei',5,'User',1107350.0),
('DI Yogyakarta',2026,'Juni',6,'User',1134744.0),
('DKI Jakarta',2026,'Januari',1,'User',6181805.0),
('DKI Jakarta',2026,'Februari',2,'User',6243274.0),
('DKI Jakarta',2026,'Maret',3,'User',6312852.0),
('DKI Jakarta',2026,'April',4,'User',6404541.0),
('DKI Jakarta',2026,'Mei',5,'User',6515911.0),
('DKI Jakarta',2026,'Juni',6,'User',6627705.0),
('Jawa Barat',2026,'Januari',1,'User',13189957.0),
('Jawa Barat',2026,'Februari',2,'User',13375529.0),
('Jawa Barat',2026,'Maret',3,'User',13583068.0),
('Jawa Barat',2026,'April',4,'User',13876239.0),
('Jawa Barat',2026,'Mei',5,'User',14171857.0),
('Jawa Barat',2026,'Juni',6,'User',14486013.0),
('Jawa Tengah',2026,'Januari',1,'User',8318297.0),
('Jawa Tengah',2026,'Februari',2,'User',8408251.0),
('Jawa Tengah',2026,'Maret',3,'User',8534303.0),
('Jawa Tengah',2026,'April',4,'User',8714073.0),
('Jawa Tengah',2026,'Mei',5,'User',8895267.0),
('Jawa Tengah',2026,'Juni',6,'User',9087984.0),
('Jawa Timur',2026,'Januari',1,'User',9120474.0),
('Jawa Timur',2026,'Februari',2,'User',9233646.0),
('Jawa Timur',2026,'Maret',3,'User',9373721.0),
('Jawa Timur',2026,'April',4,'User',9577178.0),
('Jawa Timur',2026,'Mei',5,'User',9785463.0),
('Jawa Timur',2026,'Juni',6,'User',10006311.0),
('Banten',2026,'Januari',1,'User',3288297.0),
('Banten',2026,'Februari',2,'User',3347088.0),
('Banten',2026,'Maret',3,'User',3421089.0),
('Banten',2026,'April',4,'User',3517488.0),
('Banten',2026,'Mei',5,'User',3616710.0),
('Banten',2026,'Juni',6,'User',3721290.0),
('DKI Jakarta',2026,'Januari',1,'Nominal',61986743339084.31),
('DKI Jakarta',2026,'Februari',2,'Nominal',58389147452535.0),
('DKI Jakarta',2026,'Maret',3,'Nominal',76029048164069.0),
('DKI Jakarta',2026,'April',4,'Nominal',69392242263353.0),
('DKI Jakarta',2026,'Mei',5,'Nominal',70932800331764.0),
('DKI Jakarta',2026,'Juni',6,'Nominal',70826303574883.0),
('Jawa Barat',2026,'Januari',1,'Nominal',26035404336952.54),
('Jawa Barat',2026,'Februari',2,'Nominal',25726422544656.0),
('Jawa Barat',2026,'Maret',3,'Nominal',34901233729191.0),
('Jawa Barat',2026,'April',4,'Nominal',40019168854764.0),
('Jawa Barat',2026,'Mei',5,'Nominal',37026210807960.0),
('Jawa Barat',2026,'Juni',6,'Nominal',48229172344311.0),
('Jawa Timur',2026,'Januari',1,'Nominal',13871679307752.52),
('Jawa Timur',2026,'Februari',2,'Nominal',13700361289468.0),
('Jawa Timur',2026,'Maret',3,'Nominal',16871149246917.0),
('Jawa Timur',2026,'April',4,'Nominal',16382724051652.0),
('Jawa Timur',2026,'Mei',5,'Nominal',20915772731047.0),
('Jawa Timur',2026,'Juni',6,'Nominal',19396447371357.0),
('Banten',2026,'Januari',1,'Nominal',9654336651139.81),
('Banten',2026,'Februari',2,'Nominal',9329646373374.0),
('Banten',2026,'Maret',3,'Nominal',15057656654645.0),
('Banten',2026,'April',4,'Nominal',9829659020938.0),
('Banten',2026,'Mei',5,'Nominal',11162036449843.0),
('Banten',2026,'Juni',6,'Nominal',10265539242756.0),
('Jawa Tengah',2026,'Januari',1,'Nominal',13031683677024.42),
('Jawa Tengah',2026,'Februari',2,'Nominal',11432900540570.0),
('Jawa Tengah',2026,'Maret',3,'Nominal',15314719146468.0),
('Jawa Tengah',2026,'April',4,'Nominal',14219859759262.0),
('Jawa Tengah',2026,'Mei',5,'Nominal',18855664885947.0),
('Jawa Tengah',2026,'Juni',6,'Nominal',17299704286148.0),
('DI Yogyakarta',2026,'Januari',1,'Nominal',5674602365880.25),
('DI Yogyakarta',2026,'Februari',2,'Nominal',5209553053850.0),
('DI Yogyakarta',2026,'Maret',3,'Nominal',6515184294172.0),
('DI Yogyakarta',2026,'April',4,'Nominal',6842542941480.0),
('DI Yogyakarta',2026,'Mei',5,'Nominal',9103260714593.0),
('DI Yogyakarta',2026,'Juni',6,'Nominal',8796537595127.0),
('DKI Jakarta',2026,'Januari',1,'Volume',696817073.37),
('DKI Jakarta',2026,'Februari',2,'Volume',669651960.0),
('DKI Jakarta',2026,'Maret',3,'Volume',827265909.0),
('DKI Jakarta',2026,'April',4,'Volume',793584748.0),
('DKI Jakarta',2026,'Mei',5,'Volume',822964523.0),
('DKI Jakarta',2026,'Juni',6,'Volume',821007550.0),
('Jawa Barat',2026,'Januari',1,'Volume',298916330.1),
('Jawa Barat',2026,'Februari',2,'Volume',297159227.0),
('Jawa Barat',2026,'Maret',3,'Volume',369194870.0),
('Jawa Barat',2026,'April',4,'Volume',477680762.0),
('Jawa Barat',2026,'Mei',5,'Volume',435616400.0),
('Jawa Barat',2026,'Juni',6,'Volume',550231217.0),
('Jawa Timur',2026,'Januari',1,'Volume',146455731.89),
('Jawa Timur',2026,'Februari',2,'Volume',150772996.0),
('Jawa Timur',2026,'Maret',3,'Volume',189979182.0),
('Jawa Timur',2026,'April',4,'Volume',196843478.0),
('Jawa Timur',2026,'Mei',5,'Volume',241981863.0),
('Jawa Timur',2026,'Juni',6,'Volume',218121645.0),
('Banten',2026,'Januari',1,'Volume',130524886.11),
('Banten',2026,'Februari',2,'Volume',113676748.0),
('Banten',2026,'Maret',3,'Volume',123897445.0),
('Banten',2026,'April',4,'Volume',119081087.0),
('Banten',2026,'Mei',5,'Volume',142555395.0),
('Banten',2026,'Juni',6,'Volume',138844081.0),
('Jawa Tengah',2026,'Januari',1,'Volume',149055607.01),
('Jawa Tengah',2026,'Februari',2,'Volume',122432851.0),
('Jawa Tengah',2026,'Maret',3,'Volume',164577993.0),
('Jawa Tengah',2026,'April',4,'Volume',151420025.0),
('Jawa Tengah',2026,'Mei',5,'Volume',225214963.0),
('Jawa Tengah',2026,'Juni',6,'Volume',201102379.0),
('DI Yogyakarta',2026,'Januari',1,'Volume',63646967.25),
('DI Yogyakarta',2026,'Februari',2,'Volume',59056477.0),
('DI Yogyakarta',2026,'Maret',3,'Volume',75922302.0),
('DI Yogyakarta',2026,'April',4,'Volume',80168178.0),
('DI Yogyakarta',2026,'Mei',5,'Volume',102848450.0),
('DI Yogyakarta',2026,'Juni',6,'Volume',101271730.0);

-- SEED — target dummy (WAJIB diganti dengan angka resmi via Supabase Table Editor)
truncate table qris_target restart identity;
insert into qris_target (provinsi, tahun, indikator, target_nilai, keterangan) values
('DI Yogyakarta',2026,'User',1157438.88,'DUMMY - ganti dengan target resmi KPw'),
('DI Yogyakarta',2026,'Nominal',9236364474883.35,'DUMMY - ganti dengan target resmi KPw'),
('DI Yogyakarta',2026,'Volume',106335316.5,'DUMMY - ganti dengan target resmi KPw'),
('DKI Jakarta',2026,'User',6760259.1,'DUMMY - ganti dengan target resmi KPw'),
('DKI Jakarta',2026,'Nominal',74367618753627.16,'DUMMY - ganti dengan target resmi KPw'),
('DKI Jakarta',2026,'Volume',862057927.5,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Barat',2026,'User',14775733.26,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Barat',2026,'Nominal',50640630961526.55,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Barat',2026,'Volume',577742777.85,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Tengah',2026,'User',9269743.68,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Tengah',2026,'Nominal',18164689500455.4,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Tengah',2026,'Volume',211157497.95,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Timur',2026,'User',10206437.22,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Timur',2026,'Nominal',20366269739924.85,'DUMMY - ganti dengan target resmi KPw'),
('Jawa Timur',2026,'Volume',229027727.25,'DUMMY - ganti dengan target resmi KPw'),
('Banten',2026,'User',3795715.8,'DUMMY - ganti dengan target resmi KPw'),
('Banten',2026,'Nominal',10778816204893.8,'DUMMY - ganti dengan target resmi KPw'),
('Banten',2026,'Volume',145786285.05,'DUMMY - ganti dengan target resmi KPw');

-- SEED — Strategi Semester II 2026 (section 6 mockup)
truncate table qris_strategi restart identity;
insert into qris_strategi (title, deskripsi, urutan, ikon) values
('Digitalisasi Pasar','Perluasan QRIS di pasar tradisional secara bertahap.',1,'store'),
('QRIS TAP','Percepatan adopsi QRIS TAP pada transportasi, parkir, & layanan publik.',2,'tap'),
('QRIS Jelajah Kuliner','Penguatan ekosistem kuliner, destinasi wisata & kampanye merchant.',3,'utensils'),
('Pekan QRIS Nasional','Mendorong transaksi massal & awareness QRIS secara nasional.',4,'calendar-star'),
('FGD bersama PJP','Penguatan kolaborasi & sinergi implementasi QRIS dengan PJP.',5,'users'),
('Sinergi Pemda melalui ETPD','Penguatan ekosistem QRIS melalui ETPD dan kebijakan daerah.',6,'bank');

-- SEED — Executive Recommendation (section 7 mockup)
truncate table qris_rekomendasi restart identity;
insert into qris_rekomendasi (title, deskripsi, urutan, ikon) values
('Monitoring Merchant Dormant','Lakukan monitoring berkala & cleansing merchant dormant secara berkelanjutan.',1,'search'),
('Replikasi Best Practice','Replikasi strategi & praktik baik KPw berperforma terbaik ke seluruh wilayah.',2,'star'),
('Peningkatan Merchant Aktif','Fokus pada akuisisi merchant berkualitas dan aktivasi merchant.',3,'storefront'),
('Optimalisasi Volume Transaksi','Dorong peningkatan frekuensi & nominal transaksi QRIS di seluruh sektor.',4,'trending-up'),
('Perluasan Use Case QRIS & QRIS TAP','Perluas penggunaan QRIS di berbagai sektor & percepatan adopsi QRIS TAP.',5,'qrcode');

-- SEED — Key Findings (section 4 mockup)
truncate table qris_key_findings restart identity;
insert into qris_key_findings (kategori, provinsi, urutan) values
('Best Practice','Banten',1),
('Best Practice','Cirebon',2),
('Best Practice','Tasikmalaya',3),
('Best Practice','Tegal',4),
('Best Practice','Purwokerto',5),
('Best Practice','Kediri',6),
('Monitoring','DKI Jakarta',1),
('Monitoring','Jawa Tengah',2);

-- SEED — Executive Insight banner
truncate table qris_insight restart identity;
insert into qris_insight (isi, aktif) values ('Wilayah Jawa telah memasuki fase kematangan implementasi QRIS. Strategi Semester II diarahkan pada penguatan kualitas pertumbuhan melalui peningkatan merchant aktif, optimalisasi utilisasi transaksi, pengendalian merchant dormant, serta replikasi best practice antar KPw.', true);