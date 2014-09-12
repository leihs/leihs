# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können

  Grundlage:
    Angenommen ich bin Normin

  @javascript @browser @personas
  Szenario: Kalenderkomponenten
    Wenn man einen Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und der Kalender beinhaltet die folgenden Komponenten
    |Modellname                       |
    |Aktueller Monat                  |
    |Kalender                         |
    |Geräteparkauswahl                |
    |Startdatumfeld                   |
    |Enddatumfeld                     |
    |Anzahlfeld                       |
    |Artikel hinzufügen Schaltfläche  |
    |Abbrechen Schaltfläche           |

  @javascript @personas
  Szenario: Kalender Grundeinstellung
    Wenn man einen Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und das aktuelle Startdatum ist heute
    Und das Enddatum ist morgen
    Und die Anzahl ist 1
    Und es sind alle Geräteparks angezeigt die Gegenstände von dem Modell haben

  @javascript @browser @personas
  Szenario: Kalender Grundeinstellung wenn Zeitspanne bereits ausgewählt
    Angenommen man befindet sich auf der Modellliste
    Und man hat eine Zeitspanne ausgewählt
    Wenn man einen in der Zeitspanne verfügbaren Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und das Startdatum entspricht dem vorausgewählten Startdatum
    Und das Enddatum entspricht dem vorausgewählten Enddatum

  @javascript @personas
  Szenario: Kalender Grundeinstellung wenn Geräteparks bereits ausgewählt sind
    Angenommen man befindet sich auf der Modellliste
    Und man die Geräteparks begrenzt
    Und man ein Modell welches über alle Geräteparks der begrenzten Liste beziehbar ist zur Bestellung hinzufügt
    Dann öffnet sich der Kalender
    Und es wird der alphabetisch erste Gerätepark ausgewählt der teil der begrenzten Geräteparks ist
    Dann werden die Schliesstage gemäss gewähltem Gerätepark angezeigt

  @javascript  @browser @personas
  Szenario: Kalender zwischen Monaten hin und herspringen
    Angenommen man hat den Buchungskalender geöffnet
    Wenn man zwischen den Monaten hin und herspring
    Dann wird der Kalender gemäss aktuell gewähltem Monat angezeigt

  @javascript @personas
  Szenario: Kalender Sprung zu Start und Enddatum
    Angenommen man hat den Buchungskalender geöffnet
    Wenn man anhand der Sprungtaste zum aktuellen Startdatum springt
    Dann wird das Startdatum im Kalender angezeigt
    Wenn man anhand der Sprungtaste zum aktuellen Enddatum springt
    Dann wird das Enddatum im Kalender angezeigt

  @javascript @browser @personas
  Szenario: Meiner Bestellung einen Gegenstand hinzufügen
    Wenn man sich auf der Modellliste befindet die verfügbare Modelle beinhaltet
    Und man auf einem verfügbaren Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden

  @javascript @personas
  Szenario: Kalender max. Verfügbarkeit
    Angenommen man hat den Buchungskalender geöffnet
    Dann wird die maximal ausleihbare Anzahl des ausgewählten Modells angezeigt
    Und man kann maximal die maximal ausleihbare Anzahl eingeben

  @javascript @personas
  Szenario: Auswählbare Geräteparks im Kalender
    Angenommen man hat den Buchungskalender geöffnet
    Dann sind nur diejenigen Geräteparks auswählbar, welche über Kapizäteten für das ausgewählte Modell verfügen
    Und die Geräteparks sind alphabetisch sortiert

  @javascript @personas
  Szenario: Kalender Anzeige der Schliesstage
    Angenommen man hat den Buchungskalender geöffnet

  @javascript @browser @personas
  Szenario: Bestellkalender nutzen nach dem man alle Filter zurückgesetzt hat
    Angenommen ich ein Modell der Bestellung hinzufüge
    Und man sich auf der Modellliste befindet
    Und man den zweiten Gerätepark in der Geräteparkauswahl auswählt
    Wenn man "Alles zurücksetzen" wählt
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann lässt sich das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügen

  @javascript @browser @personas
  Szenario: Etwas bestellen, was nur Gruppen vorbehalten ist
    Wenn ein Modell existiert, welches nur einer Gruppe vorbehalten ist
    Dann kann ich dieses Modell ausleihen, wenn ich in dieser Gruppe bin

  @javascript @browser @personas
  Szenario: Kalender Bestellung nicht möglich, wenn Auswahl nicht verfügbar
    Wenn man versucht ein Modell zur Bestellung hinzufügen, welches nicht verfügbar ist
    Dann schlägt der Versuch es hinzufügen fehl
    Und ich sehe die Fehlermeldung, dass das ausgewählte Modell im ausgewählten Zeitraum nicht verfügbar ist

  @javascript @personas
  Szenario: Bestellkalender schliessen
    Wenn man sich auf der Modellliste befindet
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn ich den Kalender schliesse
    Dann schliesst das Dialogfenster

  @javascript @personas
  Szenario: Kalender Verfügbarkeitsanzeige
    Angenommen es existiert ein Modell für das eine Bestellung vorhanden ist
    Wenn man dieses Modell aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und wird die Verfügbarkeit des Modells im Kalendar angezeigt

  @javascript @personas
  Szenario: Kalender Verfügbarkeitsanzeige nach Änderung der Kalenderdaten
    Angenommen es existiert ein Modell für das eine Bestellung vorhanden ist
    Wenn man dieses Modell aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Wenn man ein Start und Enddatum ändert
    Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
    Wenn man die Anzahl ändert
    Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
