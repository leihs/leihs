# language: de

Funktionalität: Bestellung editieren

  @javascript @personas
  Szenario: Sperrstatus des Benutzers anzeigen
    Angenommen ich bin Pius
    Angenommen ich öffne eine Bestellung von ein gesperrter Benutzer
    Dann sehe ich neben seinem Namen den Sperrstatus 'Gesperrt!'

  @javascript @personas
  Szenario: Trotzdem genehmigen für Gruppen-Verwalter unterbinden
    Angenommen ich bin Andi
    Und eine Bestellung enhält überbuchte Modelle
    Wenn ich die Bestellung editiere
    Und die Bestellung genehmige
    Dann ist es mir nicht möglich, die Genehmigung zu forcieren

  @current
  Szenario: Zeitleiste eines Modells öffnen
    Angenommen ich bin Andi
    Wenn ich mich in der Editieransicht der Bestellung befinde 
    Und diese Bestellung enthält ein Modell
    Dann kann ich die Zeitleiste zu diesem Modell öffnen