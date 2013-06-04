# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

  Szenario: Modelllistenübersicht
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann sieht man die Explorative Suche
    Und man sieht die Modelle der ausgewählten Kategorie
    Und man sieht Sortiermöglichkeiten
    Und man sieht die Gerätepark-Auswahl
    Und man sieht die Einschränkungsmöglichkeit einen Ausleihzeitraum
    Und man sieht die Möglichkeit Modelle die im Ausleihzeitraum verfügbar sind hervozurheben

  Szenario: Ein einzelner Modelllisteneintrag
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und einen einzelner Modelleintrag beinhaltet
    | Bild                 |
    | Modellname           |
    | Herstellname         |
    | Auswahl-Schaltfläche |

  Szenario: Modellliste scrollen
    Angenommen man ist "Normin"
    Und man sieht eine Modellliste die gescroll werden muss
    Wenn bis ans ende der bereits geladenen Modelle fährt
    Dann wird der nächste Block an Modellen geladen und angezeigt
    Wenn man bis zum Ende der Liste fährt
    Dann werden die weiteren Modelle geladen und angezeigt
    Und am ender der Liste wurden alle Modelle der ausgewählten Kategorie geladen und angezeigt