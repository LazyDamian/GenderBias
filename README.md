# GenderBias

**Sichtbarkeit von Forschenden auf Wikipedia im globalen Vergleich**

Dieses Projekt untersucht, wie sichtbar Forschende aus Afrika, Asien und dem Westen auf Wikipedia sind – und ob sich Geschlecht und Herkunftsregion gegenseitig verstärken, statt sich nur zu addieren. Grundlage sind öffentliche Daten aus Wikidata, gewonnen über SPARQL-Abfragen.

## Forschungsfrage

Sind Forschende aus Afrika und Asien auf Wikipedia weniger sichtbar als ihre westlichen Kolleginnen und Kollegen, und verstärkt das Geschlecht diese Lücke zusätzlich?

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
| `gender_bias.qmd` | Quarto-Dokument mit vollständiger Datenaufbereitung, Analyse und ausführlicher inhaltlicher Einordnung. |
| `*.csv` | Rohdaten je Land, siehe Tabelle oben |

## Methodik im Überblick

Die Daten werden länderweise per SPARQL abgefragt, dedupliziert (eine Zeile pro Person für Zählungen, eine Zeile pro Person und Sprachversion für die Sprachanalyse) und anschließend zu Kennzahlen wie Wikipedia-Abdeckungsrate, Sprachversionen pro Person und Geschlechterverteilung verdichtet - jeweils regional und nach Geschlecht aufgeschlüsselt. Details und Begründungen der einzelnen Schritte stehen in `gender_bias.qmd`.

## Ergebnisse

Die vollständigen Ergebnisse, Diagramme und ihre inhaltliche Einordnung stehen in `gender_bias.qmd`.

## Setup

```r
install.packages("tidyverse")
```

Die CSV-Dateien müssen im selben Verzeichnis wie `gender_bias.qmd` liegen.

## Einschränkungen

- Die Berufsdefinition (Q901/Q1650915) schließt verwandte Kategorien wie reine Hochschullehrende aus.
- Für datenreiche Länder waren LIMIT-Beschränkungen in den SPARQL-Abfragen nötig; die Daten bilden daher nicht zwangsläufig die vollständige Population ab.
- Fehlende Geschlechtsangaben (in Asien besonders häufig, 28,8 %) werden als eigener Befund behandelt, nicht als zufälliges Rauschen.
- Die Daten spiegeln nur, wer in Wikidata überhaupt erfasst ist - das ist bereits eine Vorauswahl.

