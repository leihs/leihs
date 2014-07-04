# language: de

Funktionalität: Rüstliste

  Um die Gegenstände in den Gestellen möglichst schnell zu finden
  möchte ich als Verleiher
  dass mir das System eine Rüstliste mit Auflistung der jeweiligen Gestellen gibt

  Grundlage:
    Angenommen ich bin Pius

  @current
  Szenario: Was ich auf der Rüstliste sehen möchte
    Angenommen man öffnet eine Rüstliste
    Dann möchte ich die folgenden Bereiche in der Rüstliste sehen:
    | Bereich          |
    | Datum            |
    | Titel            |
    | Ausleihender     |
    | Verleiher        |
    | Liste            |

  @current
  Szenario: Inhalt der Rüstliste vor Aushändigung - keine Zuteilung von Inventarnummern
    Angenommen es existiert eine Aushädigung
    Dann werden alle Gegenstände wie folgt aufgelistet 
    | Spaltenname     |
    | Anzahl 		  |
    | Modellname      |
    | verfügbare Anzahl x Raum / Gestell |
    Und die Liste ist zuerst nach Ausleihdatum, dann nach Raum und Gestell sortiert
    Und die meistverfügbaren pro Ort werden zuoberst aufgeführt
    Wenn Gegenständen kein Raum oder Gestell zugeteilt sind, wird die verfügbare Anzahl und "Ort nicht definiert" angezeigt
    Und fehlende Rauminformationen bei Optionen werden als "Ort nicht definiert" angezeigt

  @current
  Szenario: Inhalt der Rüstliste nach Aushändigung - Inventarnummern sind bekannt
    Angenommen es existiert ein Vertrag
    Dann werden alle Gegenstände wie folgt aufgelistet 
    | Spaltenname     |
    | Inventarnummer  |
    | Modellname      |
    | Raum / Gestell    |
    Und die Liste ist zuerst nach Rückgabedatum, dann nach Raum und Gestell sortiert
    Wenn Gegenständen kein Raum oder Gestell zugeteilt sind, wird "Ort nicht definiert" angezeigt
    Und fehlende Rauminformationen bei Optionen werden als "Ort nicht definiert" angezeigt

  @current
  Szenario: Wo wird die Rüstliste aufgerufen
  	Wenn ich mich im Verleih im Reiter aller Verträge befinde
    Und ich sehe mindestens einen Vertrag
    Dann kann ich die Rüstliste auf den jeweiligen Vertrags-Zeilen öffnen
    Wenn ich mich im Verleih im Reiter der offenen Verträge befinde
    Und ich sehe mindestens einen Vertrag
    Dann kann ich die Rüstliste auf den jeweiligen Vertrags-Zeilen öffnen
    Wenn ich mich im Verleih im Reiter der geschlossenen Verträge befinde
    Und ich sehe mindestens einen Vertrag
    Dann kann ich die Rüstliste auf den jeweiligen Vertrags-Zeilen öffnen
    Wenn ich mich im Verleih im Reiter der genehmigten Bestellungen befinde
    Und ich sehe mindestens eine Bestellung
    Dann kann ich die Rüstliste auf den jeweiligen Bestell-Zeilen öffnen






















