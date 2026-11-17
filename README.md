# PCA dan MDS pada Indikator Kesejahteraan Rakyat di 38 Provinsi Indonesia Tahun 2024

Repositori ini berisi paper, data, dan kode R untuk penelitian **Principal Component Analysis (PCA)** dan **Multidimensional Scaling (MDS)** pada tujuh indikator kesejahteraan rakyat di 38 provinsi Indonesia tahun 2024.

Dipublikasikan pada **Seminar Nasional Statistika XIV (2026)**, Departemen Statistika FMIPA Universitas Padjadjaran.

📄 **Paper:** [`paper/Paper_PCA_MDS_Kesejahteraan_38_Provinsi_2024.pdf`](paper/Paper_PCA_MDS_Kesejahteraan_38_Provinsi_2024.pdf)

---

## Ringkasan

Kesejahteraan rakyat diukur lewat banyak indikator yang saling berkorelasi. Penelitian ini:

1. menguji kelayakan data untuk reduksi dimensi (KMO dan Bartlett's Test),
2. mereduksi 7 indikator menjadi beberapa komponen utama dengan PCA,
3. memetakan kemiripan karakteristik antarprovinsi ke ruang dua dimensi dengan Classical MDS dan Non-Metric MDS (isoMDS).

### Hasil utama

| Tahap | Hasil |
|---|---|
| KMO keseluruhan | 0,79 |
| Bartlett's Test | χ² = 182,1487; df = 21; p-value = 1,13 × 10⁻²⁷ (signifikan) |
| Komponen utama | 3 komponen (PC1–PC3) menjelaskan **85,56%** keragaman |
| PC1 (61,36%) | Kesejahteraan sosial dan kualitas hidup (IPM, sanitasi layak, kemiskinan, AHH, air minum layak) |
| PC2 (12,85%) | Ekonomi daerah (PDRB per kapita) |
| PC3 (11,35%) | Ketenagakerjaan (TPT) |
| Classical MDS | 2 dimensi menjelaskan **86,73%** (Dim 1: 71,71%; Dim 2: 15,02%) |
| Non-Metric MDS | Stress = **5,8359%** (goodness of fit baik) |

Sebagian besar provinsi mengelompok di sekitar pusat koordinat, sedangkan DKI Jakarta, Papua Tengah, dan Papua Pegunungan berada jauh dari kelompok utama karena karakteristik pembangunannya berbeda.

---

## Struktur Repositori

```
.
├── data/
│   └── Data_Project_Akhir_ADM_2.csv    # data 38 provinsi, 7 indikator, tahun 2024
├── R/
│   └── PCA_MDS.R                       # script analisis lengkap
├── hasil/                              # output (gambar & tabel) dibuat otomatis oleh script
├── paper/
│   └── Paper_PCA_MDS_Kesejahteraan_38_Provinsi_2024.pdf
└── README.md
```

---

## Data

Data sekunder cross-section tahun 2024 dari **Badan Pusat Statistik (BPS)** dan **Satu Data Kementerian Ketenagakerjaan**. Tautan sumber tiap variabel ada di Bagian 2.6 paper.

| Kolom di CSV | Variabel | Satuan |
|---|---|---|
| `IPM (Y)` | Indeks Pembangunan Manusia | indeks |
| `Persentase Penduduk Miskin` | Penduduk miskin (September 2024) | % |
| `Tingkat Pengangguran Terbuka` | TPT (Agustus 2024) | % |
| `Angka Harapan Hidup` | Rata-rata AHH laki-laki dan perempuan | tahun |
| `PRDB per kapita` | PDRB per kapita atas dasar harga berlaku | ribu rupiah |
| `% Rumah Tangga Akses Air Bersih` | Rumah tangga dengan akses air minum layak | % |
| `% Rumah Tangga Sanitasi Layak` | Rumah tangga dengan akses sanitasi layak | % |

---

## Cara Menjalankan

### Prasyarat

- [R](https://cran.r-project.org/) (disarankan versi ≥ 4.2)
- Paket: `psych`, `factoextra`, `ggplot2`, `corrplot`, `MASS`, `ggrepel` (otomatis terinstal oleh script jika belum ada)

### Langkah

```bash
git clone https://github.com/<username>/<nama-repo>.git
cd <nama-repo>
Rscript R/PCA_MDS.R
```

Atau dari RStudio: buka folder repositori sebagai project / set working directory ke folder utama, lalu jalankan `R/PCA_MDS.R`.

> Script memakai path relatif (`data/...`), jadi **working directory harus berada di folder utama repositori**.

### Output

Semua keluaran tersimpan di folder `hasil/`:

| File | Isi |
|---|---|
| `gambar1_korelasi.png` | Matriks korelasi |
| `gambar2_scree.png` | Scree plot |
| `gambar3_individu.png` | Sebaran provinsi pada ruang PC |
| `gambar4_biplot.png` | Biplot PCA |
| `gambar5_classical_mds.png` | Peta kemiripan Classical MDS |
| `gambar6_nonmetric_mds.png` | Peta kemiripan Non-Metric MDS |
| `gambar7_shepard.png` | Shepard diagram |
| `tabel3_eigenvalue.csv` | Eigenvalue dan proporsi varians |
| `tabel_loading.csv` | Loading PC1–PC3 |
| `tabel5_komunalitas.csv` | Komunalitas |
| `tabel6_jarak.csv` | Matriks jarak Euclidean |
| `tabel7_classical_mds.csv` | Koordinat Classical MDS |
| `tabel8_nonmetric_mds.csv` | Koordinat Non-Metric MDS |

Catatan: tanda (+/−) pada sumbu PC bersifat arbitrer, sehingga tanda loading dapat berbeda antar-run/versi R tanpa mengubah interpretasi.

---

## Metode Singkat

- **Standarisasi** Z-score pada seluruh variabel.
- **Kelayakan**: KMO (> 0,50) dan Bartlett's Test of Sphericity (p < 0,05).
- **Jumlah komponen**: kumulatif varians ≥ 80% (Kaiser Criterion dan scree plot sebagai pembanding).
- **MDS**: jarak Euclidean dari skor PC1–PC3, dipetakan ke 2 dimensi dengan `cmdscale` (Classical) dan `isoMDS` (Non-Metric, `set.seed(123)`).

---

## Penulis

Siti Khalilah, Mutiara Meisya Fadila, Zhafran Fakhry Sani, Pretri Seveny Yasyaf, Stefanie Aurelia Clarissa Harisusanti, dan Titi Purwandari — Departemen Statistika, Universitas Padjadjaran.

## Cara Mengutip

```
Khalilah, S., Fadila, M. M., Sani, Z. F., Yasyaf, P. S., Harisusanti, S. A. C., & Purwandari, T. (2026).
Principal Component Analysis (PCA) dan Multidimensional Scaling (MDS) pada Indikator Kesejahteraan
Rakyat di 38 Provinsi Indonesia Tahun 2024. Seminar Nasional Statistika XIV.
Departemen Statistika FMIPA Universitas Padjadjaran.
```
