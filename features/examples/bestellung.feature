# language: de

Funktionalität: Bestellung editieren

  Grundlage:
    Angenommen Personas existieren


  @javascript
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich bin Pius
    Angenommen ich öffne eine Bestellung von ein gesperrter Benutzer
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript
  Szenario: Trotzdem genehmigen für Gruppen-Verwalter unterbinden
    Angenommen ich bin Andi
    Und eine Bestellung enhält überbuchte Modelle
    Wenn ich die Bestellung editiere
    Und die Bestellung genehmige
    Dann ist es mir nicht möglich, die Genehmigung zu forcieren
