# language: de

Funktionalität: Suche

  @personas
  Szenario: Suche nach Verträgen mittels Inventarcode eines Gegenstandes der dem Vertrag zugewisen ist
    Angenommen ich bin Mike
    Und ich gebe den Inventarcode eines Gegenstandes der einem Vertrag zugewisen ist in die Suche ein
    Dann sehe ich den Vertrag dem der Gegenstand zugewisen ist in der Ergebnisanzeige

  @javascript @personas
  Szenario: Such nach einem Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat
    Angenommen ich bin Mike
    Und es existiert ein Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat
    Wenn man nach dem Benutzer sucht
    Dann sieht man alle Veträge des Benutzers
    Und der Name des Benutzers ist in jeder Vertragslinie angezeigt
    Und die Personalien des Benutzers werden im Tooltip angezeigt

  @javascript @personas
  Szenario: Keine Aushändigung ohne vorherige Genehmigung
    Angenommen ich bin Pius
    Und es gibt einen Benutzer, mit einer nicht genehmigter Bestellung
    Wenn man nach diesem Benutzer sucht
    Dann kann ich die nicht genehmigte Bestellung des Benutzers nicht aushändigen ohne sie vorher zu genehmigen

  @javascript @personas
  Szenario: Kein 'zeige alle gefundenen Verträge' Link
    Angenommen ich bin Mike
    Und es existiert ein Benutzer mit mindestens 3 und weniger als 5 Verträgen
    Wenn man nach dem Benutzer sucht
    Dann sieht man alle unterschriebenen und geschlossenen Veträge des Benutzers
    Und man sieht keinen Link 'Zeige alle gefundenen Verträge'

  @javascript @personas
  Szenario: Anzeige von ausgemusterten Gegenständen
    Angenommen ich bin Mike
    Und es gibt einen geschlossenen Vertrag mit ausgemustertem Gegenstand
    Wenn ich anhand der Inventarnummer nach diesem Gegenstand global suche
    Dann sehe den Gegenstand ihn im Gegenstände-Container
    Und wenn ich über die Liste der Gegenstände auf der Vertragslinie hovere
    Dann sehe ich im Tooltip das Modell dieses Gegenstandes

  @javascript @personas
  Szenario: Anzeige von Gegenständen eines anderen Geräteparks in geschlossenen Verträgen
    Angenommen ich bin Mike
    Und es gibt einen geschlossenen Vertrag mit einem Gegenstand, wofür ein anderer Gerätepark verantwortlich und Besitzer ist
    Wenn ich anhand der Inventarnummer nach diesem Gegenstand global suche
    Dann sehe ich keinen Gegenstände-Container
    Und wenn ich über die Liste der Gegenstände auf der Vertragslinie hovere
    Dann sehe ich im Tooltip das Modell dieses Gegenstandes

  @personas @javascript
  Szenariogrundriss: Probleme bei Gegenständen in globaler Suche anzeigen
    Angenommen ich bin Mike
    Und es gibt in meinem Gerätepark einen "<Zustand>"en Gegenstand
    Wenn ich anhand der Inventarnummer nach diesem Gegenstand global suche
    Dann sehe ich diesen Gegenstand im Gegenstände-Container
    Und die Gegenstandszeile ist mit "<Zustand>" in rot ausgezeichnet
    Beispiele:
      | Zustand          |
      | Defekt           |
      | Ausgemustert     |
      | Unvollständig    |
      | Nicht ausleihbar |
