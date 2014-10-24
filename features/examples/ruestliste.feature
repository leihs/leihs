# language: de

Funktionalität: Rüstliste

  Um die Gegenstände in den Gestellen möglichst schnell zu finden
  möchte ich als Verleiher
  dass mir das System eine Rüstliste mit Auflistung der jeweiligen Gestellen gibt

  Grundlage:
    Angenommen ich bin Pius

  @personas
  Szenario: Was ich auf der Rüstliste sehen möchte
    Wenn man öffnet eine Rüstliste
    Dann möchte ich die folgenden Bereiche in der Rüstliste sehen:
    | Bereich          |
    | Datum            |
    | Titel            |
    | Ausleihender     |
    | Verleiher        |
    | Liste            |

  @personas @javascript @browser
  Szenario: Inhalt der Rüstliste vor Aushändigung - keine Zuteilung von Inventarcode
    Angenommen es gibt eine Aushändigung mit mindestens einem nicht problematischen Modell und einer Option
    Und ich die Aushändigung öffne
    Und ein Gegenstand zugeteilt ist und diese Zeile markiert ist
    Und einer Zeile noch kein Gegenstand zugeteilt ist und diese Zeile markiert ist
    Und eine Option markiert ist
    Wenn man öffnet die Rüstliste
    Dann sind die Listen zuerst nach Ausleihdatum sortiert
    Und jede Liste beinhaltet folgende Spalten:
    | Spaltenname                        |
    | Anzahl                             |
    | Inventarcode                       |
    | Modellname                         |
    | verfügbare Anzahl x Raum / Gestell |
    Und innerhalb jeder Liste wird nach Modell, dann nach Raum und Gestell des meistverfügbaren Ortes sortiert
    Und in der Liste wird der Inventarcode des zugeteilten Gegenstandes mit Angabe dessen Raums und Gestells angezeigt
    Und in der Liste wird der nicht zugeteilte Gegenstand ohne Angabe eines Inventarcodes angezeigt
    Und Gegenständen kein Raum oder Gestell zugeteilt sind, wird die verfügbare Anzahl für den Kunden und "x Ort nicht definiert" angezeigt
    Und fehlende Rauminformationen bei Optionen werden als "Ort nicht definiert" angezeigt

  @personas @javascript @browser
  Szenario: Inhalt der Rüstliste vor Aushändigung - nicht verfügbare Gegenstände
    Angenommen es gibt eine Aushändigung mit mindestens einer problematischen Linie
    Und ich die Aushändigung öffne
    Und einer Zeile noch kein Gegenstand zugeteilt ist und diese Zeile markiert ist
    Wenn man öffnet die Rüstliste
    Dann sind die Listen zuerst nach Ausleihdatum sortiert
    Und nicht verfügbaren Gegenständen, wird "Nicht verfügbar" angezeigt

  @personas @javascript @browser
  Szenario: Inhalt der Rüstliste vor Aushändigung - nicht zugeteilt Raum und Gestell
    Angenommen es gibt eine Aushändigung mit mindestens einem Gegenstand ohne zugeteilt Raum und Gestell
    Und ich die Aushändigung öffne
    Und einer Zeile mit einem Gegenstand ohne zugeteilt Raum und Gestell markiert ist
    Wenn man öffnet die Rüstliste
    Dann Gegenständen kein Raum oder Gestell zugeteilt sind, wird "Ort nicht definiert" angezeigt

  @personas @javascript
  Szenario: Inhalt der Rüstliste nach Aushändigung - Inventarcodes sind bekannt
    Wenn man öffnet die Rüstliste für einen unterschriebenen Vertrag
    Dann sind die Listen zuerst nach Rückgabedatum sortiert
    Und jede Liste beinhaltet folgende Spalten:
    | Spaltenname    |
    | Anzahl         |
    | Inventarcode   |
    | Modellname     |
    | Raum / Gestell |
    Und innerhalb jeder Liste wird nach Raum und Gestell sortiert
    Wenn Gegenständen kein Raum oder Gestell zugeteilt sind, wird "Ort nicht definiert" angezeigt
    Und fehlende Rauminformationen bei Optionen werden als "Ort nicht definiert" angezeigt

  @personas @javascript
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
    Wenn ich mich im Verleih in einer Aushändigung befinde
    Und ich mindestens eine Zeile in dieser Aushändigung markiere
    Dann kann ich die Rüstliste öffnen





















