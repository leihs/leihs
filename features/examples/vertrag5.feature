# language: de

Funktionalität: Vertrag

  Um eine Aushändigung durchzuführen/zu dokumentieren
  möchte ich als Verleiher
  das mir das System einen Vertrag bereitstellen kann

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"

  @javascript
  Szenario: Inhalt der Liste 1 und Liste 2
    Angenommen man öffnet einen Vertrag bei der Aushändigung
    Dann beinhalten Liste 1 und Liste 2 folgende Spalten:
    | Spaltenname   |
    | Anzahl        |
    | Inventarcode  |
    | Modellname    |
    | Enddatum      |
    | Rückgabedatum / Rücknehmende Person |

  @javascript
  Szenario: Rücknehmende Person
    Angenommen man öffnet einen Vertrag bei der Rücknahme
    Dann sieht man bei den betroffenen Linien die rücknehmende Person im Format "V. Nachname"
