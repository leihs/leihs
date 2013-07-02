Funktionalität: Bestellübersicht

Um die Bestellung in der Übersicht zu sehen
möchte ich als Ausleiher
die Möglichkeit haben meine bestellten Gegenstände in der Übersicht zu sehen

Szenario: Bestellübersicht Auflistung der Gegenstände
  Angenommen ich habe Gegenstände der Bestellung hinzugefügt
  Wenn ich die Bestellübersicht öffne
  Dann sehe ich die Einträge gruppiert nach Startdatum und Gerätepark
  Und die Modelle sind alphabetisch sortiert
  Und für jeden Eintrag sehe ich die folgenden Informationen
  |Picture|
  |Anzahl|
  |Modellname|
  |Hersteller|
  |Anzahl der Tage|
  |Enddatum|
  |die versch. Aktionen|
  
Szenario: Bestellübersicht Aktion 'löschen'
  Angenommen ich habe Gegenstände der Bestellung hinzugefügt
  Wenn ich die Bestellübersicht öffne
  Und ich einen Eintrag lösche
  Dann sind die Gegenstände wieder zur Ausleihe verfügbar
  Dann wird der Eintrag aus der Bestellung entfernt
  
Szenario: Bestellübersicht Bestellung löschen
  Angenommen ich habe Gegenstände der Bestellung hinzugefügt
  Wenn ich die Bestellübersicht öffne
  Und ich die Bestellung lösche
  Dann werde ich gefragt ob ich die Bestellung wirklich löschen möchte
  Und alle Einträge werden aus der Bestellung gelöscht
  Und die Gegenstände sind wieder zur Ausleihe verfügbar
  Und ich befinde mich wieder auf der Startseite
  
Szenario: Bestellübersicht Bestellen
  Angenommen ich habe Gegenstände der Bestellung hinzugefügt
  Wenn ich die Bestellübersicht öffne
  Und ich einen Zweck eingebe
  Und ich die Bestellung abschliesse
  Dann ändert sich der Status der Bestellung auf Abgeschickt
  Und der Ausleiher erhält eine Bestellbestätigung 
  Und in der Bestellbestätigung wird mitgeteilt, dass die Bestellung in Kürze bearbeitet wird
  Und der Ausleiher wird auf die Startseite geführt
  
Szenario: Bestellübersicht Zweck nicht eingegeben
  Angenommen ich habe Gegenstände der Bestellung hinzugefügt
  Wenn ich die Bestellübersicht öffne
  Und der Zweck nicht abgefüllt wird
  Dann hat der Benutzer keine Möglichkeit die Bestellung abzuschicken
  
  
  
