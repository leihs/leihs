# language: de

Funktionalität: Suche

  Grundlage:
    Angenommen Personas existieren

  Szenario: Suche nach Verträgen mittels Inventarcode eines Gegenstandes der dem Vertrag zugewisen ist 
    Angenommen man ist "Mike"
    Und ich gebe den Inventarcode eines Gegenstandes der einem Vertrag zugewisen ist in die Suche ein
    Dann sehe ich den Vertrag dem der Gegenstand zugewisen ist in der Ergebnisanzeige

  @javascript
  Szenario: Such nach einem Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat
    Angenommen man ist "Mike"
    Und es existiert ein Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat
    Wenn man nach dem Benutzer sucht
    Dann sieht man alle Veträge des Benutzers
    Und der Name des Benutzers ist in jeder Vertragslinie angezeigt
    Und die Personalien des Benutzers werden im Tooltip angezeigt

  @javascript
  Szenario: Keine Aushändigung ohne vorherige Genehmigung
    Angenommen man ist "Pius"
    Und es gibt einen Benutzer, mit einer nicht genehmigter Bestellung
    Wenn man nach diesem Benutzer sucht
    Dann kann ich die nicht genehmigte Bestellung des Benutzers nicht aushändigen ohne sie vorher zu genehmigen
