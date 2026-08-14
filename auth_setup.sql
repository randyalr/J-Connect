-- ============================================================
-- Setup Autentikasi: Dashboard Assessment QRIS Wilayah Jawa
-- Jalankan di Supabase SQL Editor SETELAH schema.sql (sekali saja)
-- ============================================================

-- 1) Trigger penegak domain email @bi.go.id di level database.
--    Ini garis pertahanan UTAMA — validasi di JS/frontend hanya untuk UX,
--    karena JS selalu bisa dilewati (mis. panggil API langsung). Trigger ini
--    berjalan di dalam transaksi pembuatan user auth.users, sehingga
--    pendaftaran dengan domain selain @bi.go.id akan GAGAL di database,
--    apa pun cara pendaftarannya (form website, curl, aplikasi lain, dst).
create or replace function public.enforce_bi_email_domain()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.email is not null and new.email !~* '@bi\.go\.id$' then
    raise exception 'Pendaftaran hanya diperbolehkan menggunakan email @bi.go.id'
      using errcode = 'P0001';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_enforce_bi_email_domain on auth.users;
create trigger trg_enforce_bi_email_domain
  before insert on auth.users
  for each row execute function public.enforce_bi_email_domain();

-- 2) Perketat RLS: sebelumnya (di schema.sql) tabel qris_* bisa dibaca oleh
--    siapa saja (anon, belum login). Setelah ada login, ubah ke "hanya user
--    yang sudah login" agar sejalan dengan tujuan penambahan halaman auth.
--    Jalankan blok ini untuk MENGGANTI policy lama.
do $$
declare
  t text;
begin
  foreach t in array array['qris_rekap_bulanan','qris_target','qris_strategi',
                            'qris_rekomendasi','qris_key_findings','qris_insight']
  loop
    execute format('drop policy if exists %I on %I;', 'Public read ' || t, t);
    execute format(
      'create policy %I on %I for select using (auth.role() = ''authenticated'');',
      'Authenticated read ' || t, t
    );
  end loop;
end $$;

-- ============================================================
-- Catatan konfigurasi tambahan (dilakukan di Dashboard, bukan SQL):
-- ============================================================
-- a) Authentication > URL Configuration > Site URL:
--      isi dengan URL website production (mis. https://<user>.github.io/qris-dashboard-portal/)
--      Ini WAJIB agar tautan di email "Lupa Password" mengarah kembali ke website yang benar.
-- b) Authentication > URL Configuration > Redirect URLs:
--      tambahkan URL yang sama (dan http://localhost:8080/ jika sedang uji coba lokal).
-- c) Authentication > Providers > Email:
--      "Confirm email" ON (disarankan) -> user wajib klik link verifikasi sebelum bisa login.
--      Jika OFF -> user langsung punya sesi aktif begitu signUp() berhasil (auto-login).
-- d) Authentication > Emails: sesuaikan template "Reset Password" & "Confirm signup"
--      (opsional) agar menggunakan bahasa Indonesia / branding BI.
