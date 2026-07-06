# ============================================================
# Gender-Aspekte der Data Science — Teamprojekt
# Analyse: Sichtbarkeit von Forschenden auf Wikipedia
# Vergleich: Afrika / Asien / Westen
# ============================================================

library(tidyverse)
# ============================================================
# 1. DATEN LADEN & ZUSAMMENFÜHREN
# ============================================================

africa <- read_csv("Afrika.csv") %>%
  mutate(region = "Africa")

asia <- bind_rows(
  read_csv("China.csv"),
  read_csv("Indien.csv"),
  read_csv("Indonesien.csv"),
  read_csv("Bangladesch.csv"),
  read_csv("Pakistan.csv")
) %>%
  mutate(region = "Asia")

west <- bind_rows(
  read_csv("Deutschland.csv"),
  read_csv("Frankreich.csv"),
  read_csv("Italien.csv"),
  read_csv("UK.csv"),
  read_csv("USA.csv")
) %>%
  mutate(region = "West")

# Merge all regions
df_all <- bind_rows(africa, asia, west)

cat("=== Rohdaten ===\n")
cat("Gesamtzahl Einträge (vor Dedup):", nrow(df_all), "\n")


# ============================================================
# 2. DEDUPLIZIERUNG
# ============================================================

# Using Africa restricted to 5 most populous countries
africa_5_countries <- c("Nigeria", "Ethiopia", "Egypt",
                        "Tanzania", "Democratic Republic of the Congo")

africa_5_df <- df_all %>%
  filter(region == "Africa",
         countryLabel %in% africa_5_countries)

df_all_2 <- bind_rows(
  africa_5_df,
  df_all %>% filter(region == "Asia"),
  df_all %>% filter(region == "West")
)

# df_clean  → one row per person (for counting researchers)
# df_wiki   → one row per person per Wikipedia article (for language analysis)

df_wiki <- df_all_2 %>%
  filter(!is.na(wikipediaArticle)) %>%
  distinct(person, wikipediaArticle, .keep_all = TRUE)

df_clean <- df_all_2 %>%
  distinct(person, .keep_all = TRUE)

dupes <- nrow(df_all_2) - nrow(df_clean)

cat("Doppelte Einträge entfernt:", dupes, "\n")
cat("Eindeutige Forschende:", nrow(df_clean), "\n\n")


# ============================================================
# 3. ÜBERBLICK PRO REGION
# ============================================================

cat("=== Forschende pro Region ===\n")
df_clean %>%
  count(region, name = "n_researchers") %>%
  print()


# ============================================================
# 4. WIKIPEDIA-ABDECKUNG PRO REGION
# ============================================================

cat("\n=== Wikipedia-Abdeckung pro Region ===\n")

wiki_coverage <- df_clean %>%
  group_by(region) %>%
  summarise(
    n_total      = n(),
    n_with_wiki  = sum(!is.na(wikipediaArticle)),
    n_without    = sum(is.na(wikipediaArticle)),
    pct_with_wiki = round(n_with_wiki / n_total * 100, 1)
  ) %>%
  arrange(desc(pct_with_wiki))

print(wiki_coverage)


# ============================================================
# 5. GESCHLECHTERVERTEILUNG PRO REGION
# ============================================================

cat("\n=== Geschlechterverteilung pro Region ===\n")

gender_dist <- df_clean %>%
  group_by(region, genderLabel) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(region) %>%
  mutate(pct = round(n / sum(n) * 100, 1)) %>%
  arrange(region, desc(n))

print(gender_dist)

# Gender x Wikipedia coverage
cat("\n=== Wikipedia-Abdeckung nach Geschlecht und Region ===\n")

gender_wiki <- df_clean %>%
  filter(genderLabel %in% c("male", "female")) %>%
  group_by(region, genderLabel) %>%
  summarise(
    n_total     = n(),
    n_with_wiki = sum(!is.na(wikipediaArticle)),
    pct_wiki    = round(n_with_wiki / n_total * 100, 1),
    .groups     = "drop"
  ) %>%
  arrange(region, genderLabel)

print(gender_wiki)


# ============================================================
# 6. SPRACHABDECKUNG
# ============================================================

cat("\n=== Sprachabdeckung ===\n")

# Extract language code from Wikipedia URL
langs <- df_wiki %>%
  mutate(lang = str_extract(wikipediaArticle, "(?<=https://)([a-z-]+)(?=\\.wikipedia)")) %>%
  filter(!is.na(lang))

# Total distinct languages per region
cat("Distinct languages per region:\n")
langs %>%
  group_by(region) %>%
  summarise(n_languages = n_distinct(lang)) %>%
  print()

# Average number of Wikipedia language editions per researcher
cat("\nDurchschnittliche Sprachversionen pro Forschenden (nur mit Wiki-Artikel):\n")

lang_per_person <- langs %>%
  group_by(region, person) %>%
  summarise(n_langs = n_distinct(lang), .groups = "drop")

lang_per_person %>%
  group_by(region) %>%
  summarise(
    mean_langs   = round(mean(n_langs), 2),
    median_langs = median(n_langs),
    max_langs    = max(n_langs)
  ) %>%
  arrange(desc(mean_langs)) %>%
  print()

# Top languages per region
cat("\nTop 10 Sprachen pro Region:\n")
langs %>%
  group_by(region, lang) %>%
  summarise(n_researchers = n_distinct(person), .groups = "drop") %>%
  group_by(region) %>%
  slice_max(n_researchers, n = 10) %>%
  print(n = Inf)


# ============================================================
# 7. TOP LÄNDER PRO REGION
# ============================================================

cat("\n=== Top 10 Länder pro Region (nach Anzahl Forschender) ===\n")

df_clean %>%
  group_by(region, countryLabel) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(region) %>%
  slice_max(n, n = 10) %>%
  print(n = Inf)


# ============================================================
# 8. STRUKTURELLE MISSINGNESS: GENDER
# ============================================================

cat("\n=== Fehlende Geschlechtsangaben pro Region ===\n")

df_clean %>%
  group_by(region) %>%
  summarise(
    n_total          = n(),
    n_gender_missing = sum(is.na(genderLabel)),
    pct_missing      = round(n_gender_missing / n_total * 100, 1)
  ) %>%
  arrange(desc(pct_missing)) %>%
  print()

# ============================================================
# 9. SPRACHABDECKUNG NACH GESCHLECHT
# ============================================================

cat("\n=== Sprachversionen nach Geschlecht und Region ===\n")

langs_gender <- df_wiki %>%
  mutate(lang = str_extract(wikipediaArticle, "(?<=https://)([a-z-]+)(?=\\.wikipedia)")) %>%
  filter(!is.na(lang)) %>%
  filter(genderLabel %in% c("male", "female"))

lang_per_person_gender <- langs_gender %>%
  group_by(region, person, genderLabel) %>%
  summarise(n_langs = n_distinct(lang), .groups = "drop")

lang_per_person_gender %>%
  group_by(region, genderLabel) %>%
  summarise(
    mean_langs    = round(mean(n_langs), 2),
    median_langs  = median(n_langs),
    n_researchers = n(),
    .groups       = "drop"
  ) %>%
  arrange(region, genderLabel) %>%
  print()

cat("\n=== Global (alle Regionen zusammen) ===\n")
lang_per_person_gender %>%
  group_by(genderLabel) %>%
  summarise(
    mean_langs    = round(mean(n_langs), 2),
    median_langs  = median(n_langs),
    n_researchers = n(),
    .groups       = "drop"
  ) %>%
  print()

cat("\n=== Gender Gap pro Region (Männer minus Frauen) ===\n")
lang_per_person_gender %>%
  group_by(region, genderLabel) %>%
  summarise(mean_langs = round(mean(n_langs), 2), .groups = "drop") %>%
  pivot_wider(names_from = genderLabel, values_from = mean_langs) %>%
  mutate(gap_M_minus_F = round(male - female, 2)) %>%
  print()


# ============================================================
# 10. KONSISTENZPRÜFUNG: AFRIKA (5 LÄNDER VS. GANZER KONTINENT)
# ============================================================

cat("\n=== Konsistenzprüfung Afrika: 5 Länder vs. ganzer Kontinent ===\n")

africa_5_countries <- c("Nigeria", "Ethiopia", "Egypt",
                        "Tanzania", "Democratic Republic of the Congo")

africa_5  <- df_clean %>% filter(region == "Africa",
                                  countryLabel %in% africa_5_countries)
africa_all <- df_clean %>% filter(region == "Africa")

for (label in c("5 Länder", "Ganzer Kontinent")) {
  sub <- if (label == "5 Länder") africa_5 else africa_all
  n   <- nrow(sub)
  cat("\n---", label, "---\n")
  cat("Forschende:", n, "\n")
  cat("Mit Wikipedia:", sum(!is.na(sub$wikipediaArticle)),
      "(", round(sum(!is.na(sub$wikipediaArticle)) / n * 100, 1), "%)\n")

  gender_check <- sub %>%
    filter(genderLabel %in% c("male", "female")) %>%
    group_by(genderLabel) %>%
    summarise(
      n_total     = n(),
      n_with_wiki = sum(!is.na(wikipediaArticle)),
      pct_wiki    = round(n_with_wiki / n_total * 100, 1),
      .groups     = "drop"
    )
  print(gender_check)
}


# ============================================================
# 11. ALTERNATIVE DATENSÄTZE EXPORTIEREN
# ============================================================

# df_all_2: Africa restricted to 5 most populous countries
africa_5_df <- df_all %>%
  filter(region == "Africa",
         countryLabel %in% africa_5_countries)

df_all_2 <- bind_rows(
  africa_5_df,
  df_all %>% filter(region == "Asia"),
  df_all %>% filter(region == "West")
)

write_csv(df_all,   "df_all.csv")    # full Africa (whole continent)
write_csv(df_all_2, "df_all_2.csv")  # Africa restricted to 5 countries

