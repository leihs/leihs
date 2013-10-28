# language: de

Funktionalität: Werteliste

  Um eine konforme Werteliste aushändigen zu können
  möchte ich als Verleiher
  das mir das System für eine Auswahl eine Werteliste zur verfügung stellen kann

  Grundlage:
    Angenommen Personas existieren
    Und man ist "Pius"
    Und man öffnet eine Werteliste

  @javascript
  Szenario: Was ich auf der Werteliste sehen möchte
    Dann möchte ich die folgenden Bereiche in der Werteliste sehen:
    | Bereich          |
    | Datum            |
    | Titel            |
    | Ausleihender     |
    | Verleier         |
    | Liste            |

  @javascript
  Szenario: Der Inhalt der Werte-Liste
    Dann beinhaltet die Werte-Liste folgende Spalten:
    | Spaltenname     |
    | Laufende Nummer |
    | Inventarcode    |
    | Modellname      |
    | End Datum       |
    | Anzahl          |
    | Wert            |
    Und die Modelle in der Werteliste sind alphabetisch sortiert

  @javascript
  Szenario: Totale Werte
    Dann gibt es eine Zeile für die totalen Werte
     Und diese summierte die Spalten:
     | Spaltenname |
     | Anzahl      |
     | Wert        |
  
  Szenario: Werteliste auf Bestellübersicht ausdrucken
    Wenn ich eine Bestellung öffne 
    Und ich mehrere Linien auswähle
    Und das Werteverzeichniss öffne
    Dann sehe ich das Werteverzeichniss für die ausgewählten Linien
    Und der Preis ist der höchste Preis eines Gegenstandes eines Models innerhalb des Geräteparks
    Und der Preis einer Option ist der innerhalb des Geräteparks
    
  Szenario: Werteliste auf der Aushändigungsansicht ausdrucken
    Wenn ich eine Aushändigung öffne 
    Und ich mehrere Linien auswähle
    Und das Werteverzeichniss öffne
    Dann sehe ich das Werteverzeichniss für die ausgewählten Linien
    Und für die nicht zugewiesenen Linien ist der Preis ist der höchste Preis eines Gegenstandes eines Models innerhalb des Geräteparks
    Und für die zugewisenen Linien ist der Preis der des Gegenstandes
    Und die nicht zugewiesenen Linien sind zusammengefasst
    Und der Preis einer Option ist der innerhalb des Geräteparks
