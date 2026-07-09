# GenderBias

**Sichtbarkeit von Forschenden auf Wikipedia im globalen Vergleich**

Dieses Projekt untersucht, wie sichtbar Forschende aus Afrika, Asien und dem Westen auf Wikipedia sind – und ob sich Geschlecht und Herkunftsregion gegenseitig verstärken, statt sich nur zu addieren. Grundlage sind öffentliche Daten aus Wikidata, gewonnen über SPARQL-Abfragen.

## Forschungsfrage

Sind Forschende aus Afrika und Asien auf Wikipedia weniger sichtbar als ihre westlichen Gegenstücke, und verstärkt das Geschlecht diese Lücke zusätzlich?

Die Analyse orientiert sich an der Intersektionalitätstheorie (Crenshaw): Geschlecht und Herkunftsregion werden nicht getrennt, sondern gemeinsam betrachtet, weil sich Benachteiligungen an ihrem Schnittpunkt anders verhalten können als jede Kategorie für sich.

## Daten

Die Rohdaten stammen aus dem öffentlichen Wikidata-SPARQL-Endpunkt (Stand: Juni 2026) und umfassen Personen mit den Berufsbezeichnungen *Wissenschaftler\*in* (Q901) und *Forscher\*in* (Q1650915) aus 15 Ländern in drei Regionen:

| Region | Länder | Datei |
|---|---|---|
| Afrika | Nigeria, Äthiopien, Ägypten, Tansania, DR Kongo | `Afrika.csv` |
| Asien | China, Indien, Indonesien, Bangladesch, Pakistan | `China.csv`, `Indien.csv`, `Indonesien.csv`, `Bangladesch.csv`, `Pakistan.csv` |
| Westen | USA, Deutschland, Frankreich, Italien, UK | `USA.csv`, `Deutschland.csv`, `Frankreich.csv`, `Italien.csv`, `UK.csv` |

Jede CSV-Datei enthält pro Zeile eine Person-Artikel-Kombination mit den Spalten `person`, `personLabel`, `country`, `countryLabel`, `genderLabel` und `wikipediaArticle`. Eine Person kann mehrfach vorkommen – einmal pro Sprachversion ihres Wikipedia-Artikels.

## Dateien im Repository

| Datei | Beschreibung |
|---|---|
| `analysis.R` | R-Skript mit der vollständigen Datenaufbereitung und Analyse |
| `gender_bias.qmd` | Quarto-Dokument mit Code, Ergebnissen und ausführlicher inhaltlicher Einordnung; rendert zu HTML/PDF |
| `*.csv` | Rohdaten je Land, siehe Tabelle oben |

## Methodik im Überblick

1. **Datenerhebung** – SPARQL-Abfragen am Wikidata-Endpunkt, länderweise getrennt (der öffentliche Endpunkt reagiert bei großen, globalen Abfragen häufig mit Timeouts).
2. **Deduplizierung** – aus den Rohdaten entstehen zwei Datensätze: einer mit einer Zeile pro Person (für Zählungen wie Abdeckung oder Geschlechterverteilung) und einer mit einer Zeile pro Person und Sprachversion (für die Sprachanalyse).
3. **Berechnete Kennzahlen** – Wikipedia-Abdeckungsrate, Sprachversionen pro Person, Geschlechterverteilung, jeweils regional und nach Geschlecht aufgeschlüsselt.
4. **Vergleichsrahmen** – jeweils die fünf bevölkerungsreichsten Länder pro Region, um die Regionen untereinander fair vergleichbar zu halten.

## Zentrale Ergebnisse

- **Abdeckung:** 37,2 % der westlichen Forschenden haben einen Wikipedia-Artikel, gegenüber 22 % (Afrika) und 24 % (Asien) – die Lücke liegt vor allem zwischen Westen und Rest, nicht zwischen Afrika und Asien.
- **Geschlechtergefälle bei der Abdeckung:** im Westen fast ausgeglichen (39,0 % Männer vs. 37,3 % Frauen), in Asien groß (42 % vs. 18 %), in Afrika sogar leicht zugunsten der Frauen (22 % vs. 24 %).
- **Sprachliche Reichweite:** im Schnitt 4,2 Sprachversionen im Westen, 3,8 in Afrika, nur 2,3 in Asien.
- **Sprachliche Reichweite nach Geschlecht:** im Westen liegen Männer leicht vorn (4,6 vs. 3,4), in Afrika und Asien dagegen deutlich die Frauen (Afrika: 5,4 vs. 3,0; Asien: 3,6 vs. 2,2) – ein Hinweis darauf, dass in diesen Regionen nur besonders sichtbare Forscherinnen überhaupt einen Artikel bekommen.

Die ausführliche Einordnung dieser Befunde, inklusive Diskussion und offener Fragen, steht in `gender_bias.qmd`.

## Setup

```r
install.packages("tidyverse")
```

Die CSV-Dateien müssen im selben Verzeichnis wie `analysis.R` bzw. `gender_bias.qmd` liegen.

## Verwendung

**R-Skript ausführen:**
```r
source("analysis.R")
```

**Quarto-Report rendern** (Code, Ergebnisse und Fließtext als HTML oder PDF):
```bash
quarto render gender_bias.qmd
```

## Einschränkungen

- Die Berufsdefinition (Q901/Q1650915) schließt verwandte Kategorien wie reine Hochschullehrende aus.
- Für datenreiche Länder waren LIMIT-Beschränkungen in den SPARQL-Abfragen nötig; die Daten bilden daher nicht zwangsläufig die vollständige Population ab.
- Fehlende Geschlechtsangaben (in Asien besonders häufig, 28,8 %) werden als eigener Befund behandelt, nicht als zufälliges Rauschen.
- Die Daten spiegeln nur, wer in Wikidata überhaupt erfasst ist – das ist bereits eine Vorauswahl.

## Autor

Damian Rutz · TH Nürnberg, Social Data Science & Communication
