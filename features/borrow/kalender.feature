Funktionalität: Kalender

Um einen Gegenstand einer Bestellung hinzuzufügen
möchte ich als Ausleihender
den Gegenstand der Bestellung hinzufügen können


Szenario: Kalenderkomponenten
  Wenn man einen Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Und der Kalender beinhaltet die folgenden Komponenten
  |Modellname     |
  |Aktueller Monat|
  |Kalender|
  |Geräteparkauswahl|
  |Startdatumfeld|
  |Enddatumfeld|
  |Anzahlfeld|
  |Artikel hinzufügen Schaltfläche|
  |Abbrechen Schaltfläche|

Szenario: Kalender Grundeinstellung
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Und das aktuelle Startdatum ist heute
  Und das Enddatum ist morgen
  Und die Anzahl ist 1
  Und es sind alle Geräteparks ausgewählt

Szenario: Kalender Grundeinstellung wenn Zeitspanne bereits ausgewählt
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Und die Zeitspanne ist gewählt 
  Dann öffnet sich der Kalender
  Und das Startdatum zeigt entspricht dem vorausgewählten Startdatum
  Und das Enddatum zeigt entspricht dem vorausgewählten Enddatum 
  
Szenario: Kalender Verfügbarkeitsanzeige
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Und die Verfügbarkeit des Gegenstandes wird anhand der Zeitspanne angezeigt
  
Szenario: Kalender Verfügbarkeitsanzeige nach Änderung der Kalenderdaten
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Wenn man ein Start und Enddatum ändert
  Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
  Wenn man die Anzahl ändert
  Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
  
Szenario: Kalender max. Verfügbarkeit
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Und die maximal ausleihbare Anzahl dieses Gegenstandes wird angezeigt

Szenario: Kalender Geräteparks
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Und nur diejenigen Geräteparks sind wählbar, welche das Modell zugeteilt haben
  Und die Geräteparks sind alphabetisch sortiert
  
Szenario: Kalender Anzeige der Schliesstage
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Und die Schliesstage werden gemäss gewähltem Gerätepark angezeigt
  
Szenario: Kalender zwischen Monaten hin und herspringen
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Wenn man zwischen den Monaten hin und herspring
  Dann wird der Kalender gemäss aktuell gewähltem Monat angezeigt
  
Szenario: Kalender Sprung zu Start und Enddatum
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Wenn man anhand der Sprungtaste zum aktuellen Startdatum springt
  Dann wird das Startdatum im Kalender angezeigt
  Wenn man anhand der Sprungtaste zum aktuellen Enddatum springt
  Dann wird das Enddatum im Kalender angezeigt
  
Szenario: Kalender Gegenstand der Bestellung hinzufügen
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Wenn ich den Gegenstand der Bestellung hinzufüge
  Dann wird der Gegenstand mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt

Szenario: Kalender Bestellung nicht möglich wenn nicht verfügbar
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Wenn der Gegenstand nicht verfügbar ist
  Dann kann ich ihn nicht der Bestellung hinzufügen
  
Szenario: Kalender Bestellung nicht möglich wenn nicht verfügbar
  Wenn man den Gegenstand aus der Modellliste hinzufügt
  Dann öffnet sich der Kalender
  Wenn ich den Kalender schliesse
  Dann schliesst das Dialogfenster


  
  

  
  
 
  

