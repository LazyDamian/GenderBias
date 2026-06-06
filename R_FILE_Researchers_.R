
library(tidyverse)
setwd("C:/Users/mary-/Downloads/Gender_Data_Aspekte")
df <- read_csv("Researchers_Africa.csv")

#African Researchers Wikidata+Wikipedia Exploration#

# Deduplicate on person QID
df_clean <- df %>% distinct(person, .keep_all = TRUE)

total <- nrow(df_clean)
dupes <- nrow(df) - total

with_wiki <- df_clean %>% filter(!is.na(wikipediaArticle)) %>% nrow()
without_wiki <- total - with_wiki
with_birth <- df_clean %>% filter(!is.na(placeOfBirthLabel)) %>% nrow()
without_birth <- total - with_birth

cat("Gesamtzahl:", total, "\n")
cat("Doppelte Einträge entfernt:", dupes, "\n")
cat("Mit Wikipedia-Artikel:", with_wiki, "/ Ohne:", without_wiki, "\n")
cat("Mit Geburtsort:", with_birth, "/ Ohne:", without_birth, "\n")

# Auffälligkeiten
df_clean %>% count(genderLabel, sort = TRUE) %>% print()
df_clean %>% count(countryLabel, sort = TRUE) %>% head(10) %>% print()


#LANGUAGE COVERAGE#

# Extract language code from the Wikipedia URL
langs <- df %>%
  filter(!is.na(wikipediaArticle)) %>%
  mutate(lang = str_extract(wikipediaArticle, "(?<=https://)([a-z-]+)(?=\\.wikipedia)")) %>%
  filter(!is.na(lang))

# Total distinct languages
n_langs <- n_distinct(langs$lang)
cat("Total languages covering African researchers:", n_langs, "\n")

# Count researchers per language
lang_counts <- langs %>%
  group_by(lang) %>%
  summarise(n_researchers = n_distinct(person)) %>%
  arrange(desc(n_researchers))

print(lang_counts, n = Inf)