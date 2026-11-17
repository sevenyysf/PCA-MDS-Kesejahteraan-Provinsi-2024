#   ANALISIS PCA + MDS - INDIKATOR KESEJAHTERAAN 38 PROVINSI 2024
# ============================================================

packages <- c("psych", "factoextra", "ggplot2", "corrplot", "MASS", "ggrepel")
new_pkg  <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(new_pkg)) install.packages(new_pkg)
library(psych); library(factoextra); library(ggplot2)
library(corrplot); library(MASS); library(ggrepel)

# folder keluaran (gambar & tabel)
out_dir <- "hasil"
dir.create(out_dir, showWarnings = FALSE)
# ---- 1. DATA ----
# Jalankan dari folder utama repositori (set working directory ke sana).
data_path <- file.path("data", "Data_Project_Akhir_ADM_2.csv")
if (!file.exists(data_path)) {
  stop("File data tidak ditemukan: ", data_path,
       "\nPastikan working directory = folder utama repositori.")
}
data_raw <- read.csv(data_path, check.names = FALSE, stringsAsFactors = FALSE)
data_raw <- data_raw[data_raw$Provinsi != "INDONESIA", ]

provinsi <- data_raw[, 1]
data_num <- data_raw[, -1]

# nama variabel bersih (urutan sesuai CSV)
colnames(data_num) <- c("IPM", "Penduduk Miskin", "TPT", "AHH",
                        "PDRB per Kapita", "Air Bersih", "Sanitasi Layak")
rownames(data_num) <- provinsi

data_clean     <- na.omit(data_num)
provinsi_clean <- rownames(data_clean)
n_prov <- nrow(data_clean)
cat("Provinsi:", n_prov, "| Variabel:", ncol(data_clean), "\n")   # 38 | 7

# ---- 2. UJI KELAYAKAN ----
cor_matrix <- cor(data_clean)
print(round(cor_matrix, 2))

png(file.path(out_dir, "gambar1_korelasi.png"), 1800, 1500, res = 220)
corrplot(cor_matrix, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black", tl.cex = 0.85,
         number.cex = 0.8, mar = c(0, 0, 1.5, 0),
         title = "Matriks Korelasi Indikator Kesejahteraan Provinsi")
dev.off()

kmo_result <- KMO(data_clean)
print(kmo_result)
bartlett_result <- cortest.bartlett(cor(data_clean), n = n_prov)
print(bartlett_result)

# ---- 3. PCA ----
pca_model <- prcomp(scale(data_clean))   # z-score; tanda (+/-) sumbu PC bersifat arbitrer

eigenvalue  <- pca_model$sdev^2
eigen_table <- data.frame(
  Komponen   = paste0("PC", seq_along(eigenvalue)),
  Eigenvalue = round(eigenvalue, 4),
  Proporsi   = round(eigenvalue / sum(eigenvalue) * 100, 2),
  Kumulatif  = round(cumsum(eigenvalue / sum(eigenvalue)) * 100, 2)
)
print(eigen_table)

# Kriteria: kumulatif varians >= 80% (Kaiser dilaporkan sebagai pembanding)
n_kaiser <- sum(eigenvalue > 1)
n_pc <- which(cumsum(eigenvalue / sum(eigenvalue)) >= 0.80)[1]
cat(sprintf("Kaiser: %d PC | Kumulatif >= 80%%: %d PC (%.2f%%)\n",
            n_kaiser, n_pc, eigen_table$Kumulatif[n_pc]))

# ---- Loading = eigenvector x sqrt(eigenvalue) ----
loadings_mat <- sweep(pca_model$rotation[, 1:n_pc], 2,
                      pca_model$sdev[1:n_pc], "*")
cat("\nLoading PC1-PC", n_pc, ":\n", sep = "")
print(round(loadings_mat, 3))

# ---- Komunalitas dari LOADING (bukan eigenvector) ----
communalities <- rowSums(loadings_mat^2)
cat("\nKomunalitas:\n"); print(round(communalities, 3))
cat("Cek: sum =", round(sum(communalities), 4),
    "| sum eigenvalue PC1-PC", n_pc, "=", round(sum(eigenvalue[1:n_pc]), 4), "\n")

write.csv(eigen_table,  file.path(out_dir, "tabel3_eigenvalue.csv"), row.names = FALSE)
write.csv(round(loadings_mat, 3), file.path(out_dir, "tabel_loading.csv"))
write.csv(data.frame(Variabel = names(communalities),
                     Komunalitas = round(communalities, 3)),
          file.path(out_dir, "tabel5_komunalitas.csv"), row.names = FALSE)

# ---- Plot PCA ----
simpan <- function(nama, expr, w = 2000, h = 1600) {
  png(file.path(out_dir, nama), w, h, res = 220); print(expr); dev.off()
}
simpan("gambar2_scree.png",
       fviz_eig(pca_model, addlabels = TRUE,
                ylim = c(0, max(eigen_table$Proporsi) + 5),
                main = "Scree Plot PCA - Indikator Kesejahteraan Provinsi"),
       1600, 1200)
simpan("gambar3_individu.png",
       fviz_pca_ind(pca_model, repel = TRUE, col.ind = "cos2",
                    gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                    title = "Sebaran Provinsi pada Ruang PC"), 2200, 1700)
simpan("gambar4_biplot.png",
       fviz_pca_biplot(pca_model, repel = TRUE, col.ind = "steelblue",
                       col.var = "tomato", title = "Biplot PCA - Provinsi & Indikator"),
       2200, 1700)

# ---- Skor PC sebagai input MDS ----
scores_pc <- pca_model$x[, 1:n_pc]

# ---- 4. MDS ----
dist_matrix <- dist(scores_pc, method = "euclidean")
write.csv(round(as.matrix(dist_matrix), 2), file.path(out_dir, "tabel6_jarak.csv"))

# (A) Classical MDS
mds_classic <- cmdscale(dist_matrix, eig = TRUE, k = 2)
eig_pos  <- mds_classic$eig[mds_classic$eig > 1e-8]     # buang eigenvalue ~0
prop_dim <- eig_pos / sum(eig_pos)
pct_dim1 <- round(prop_dim[1] * 100, 2)
pct_dim2 <- round(prop_dim[2] * 100, 2)
cat(sprintf("\nClassical MDS: Dim1 %.2f%%, Dim2 %.2f%%, total %.2f%%\n",
            pct_dim1, pct_dim2, pct_dim1 + pct_dim2))

coord_classic <- data.frame(Provinsi = provinsi_clean,
                            Dim1 = mds_classic$points[, 1],
                            Dim2 = mds_classic$points[, 2])
rownames(coord_classic) <- NULL
print(head(transform(coord_classic, Dim1 = round(Dim1, 3), Dim2 = round(Dim2, 3))))
write.csv(round_df <- transform(coord_classic, Dim1 = round(Dim1, 3), Dim2 = round(Dim2, 3)),
          file.path(out_dir, "tabel7_classical_mds.csv"), row.names = FALSE)

simpan("gambar5_classical_mds.png",
  ggplot(coord_classic, aes(Dim1, Dim2, label = Provinsi)) +
    geom_point(color = "steelblue", size = 3) +
    geom_text_repel(size = 2.8, max.overlaps = 40) +
    labs(title = paste0("Peta Kemiripan ", n_prov, " Provinsi - Classical MDS"),
         subtitle = paste0("Berdasarkan Skor PC1-PC", n_pc,
                           " (merangkum ", eigen_table$Kumulatif[n_pc], "% informasi)"),
         x = paste0("Dimensi 1 (", pct_dim1, "%)"),
         y = paste0("Dimensi 2 (", pct_dim2, "%)")) +
    theme_minimal(base_size = 11) + theme(plot.title = element_text(face = "bold")),
  2200, 1700)

# (B) Non-metric MDS
set.seed(123)
mds_nonmetric <- isoMDS(dist_matrix, k = 2)
cat(sprintf("Non-metric MDS stress: %.4f%%\n", mds_nonmetric$stress))

coord_nonmetric <- data.frame(Provinsi = provinsi_clean,
                              Dim1 = mds_nonmetric$points[, 1],
                              Dim2 = mds_nonmetric$points[, 2])
rownames(coord_nonmetric) <- NULL
write.csv(transform(coord_nonmetric, Dim1 = round(Dim1, 3), Dim2 = round(Dim2, 3)),
          file.path(out_dir, "tabel8_nonmetric_mds.csv"), row.names = FALSE)

simpan("gambar6_nonmetric_mds.png",
  ggplot(coord_nonmetric, aes(Dim1, Dim2, label = Provinsi)) +
    geom_point(color = "tomato", size = 3) +
    geom_text_repel(size = 2.8, max.overlaps = 40) +
    labs(title = paste0("Peta Kemiripan ", n_prov, " Provinsi - Non-Metric MDS (isoMDS)"),
         subtitle = paste0("Berdasarkan Skor PC1-PC", n_pc,
                           " | Stress = ", round(mds_nonmetric$stress, 2), "%"),
         x = "Dimensi 1", y = "Dimensi 2") +
    theme_minimal(base_size = 11) + theme(plot.title = element_text(face = "bold")),
  2200, 1700)

# (C) Shepard diagram (garis merah = regresi isotonik / disparitas)
sh <- Shepard(dist_matrix, mds_nonmetric$points)
png(file.path(out_dir, "gambar7_shepard.png"), 1600, 1600, res = 220)
plot(sh, pch = 20, col = "gray40",
     xlab = "Jarak Asli (dari Skor PC)", ylab = "Jarak Hasil MDS",
     main = "Shepard Diagram - Non-Metric MDS")
lines(sh$x, sh$yf, type = "S", col = "red", lwd = 1.5)
dev.off()

# ---- 5. RINGKASAN ----
cat("\n==== RINGKASAN ====\n")
cat(sprintf("Provinsi %d | Variabel %d | PC dipertahankan %d (%.2f%%)\n",
            n_prov, ncol(data_clean), n_pc, eigen_table$Kumulatif[n_pc]))
cat(sprintf("KMO %.2f | Bartlett chi2 %.4f, df %d, p %.3g\n",
            kmo_result$MSA, bartlett_result$chisq, bartlett_result$df,
            bartlett_result$p.value))
cat(sprintf("Classical MDS: %.2f%% + %.2f%% | isoMDS stress %.2f%%\n",
            pct_dim1, pct_dim2, mds_nonmetric$stress))

cat("\nOutput tersimpan di:", normalizePath(out_dir), "\n")
