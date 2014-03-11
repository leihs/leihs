# language: de

Funktionalität: Delegation

  @javascript
  Szenario: Delegation löschen
    Angenommen ich bin Gino
    Und ich in den Admin-Bereich wechsle
    Und ich befinde mich im Reiter 'Benutzer'
    Wenn keine Bestellung, Aushändigung oder ein Vertrag für eine Delegation besteht
    Und wenn für diese Delegation keine Zugriffsrechte für irgendwelches Gerätepark bestehen
    Dann kann ich diese Delegation löschen

  #  ANZEIGE BACKEND

  @javascript
  Szenario: Anzeige der Bestellungen für eine Delegation
    Angenommen ich bin Pius
    Und es wurde für eine Delegation eine Bestellung erstellt
    Und ich befinde mich in dieser Bestellung
    Dann sehe ich den Namen der Delegation
    Und ich sehe die Kontaktperson

  @javascript
  Szenario: Definition Kontaktperson auf Auftragserstellung
    Angenommen ich bin Julie
    Wenn ich eine Bestellung für eine Delegationsgruppe erstelle
    Dann bin ich die Kontaktperson für diesen Auftrag
    Angenommen ich bin Pius
    Wenn ich die Gegenstände für die Delegation an "Mina" aushändige
    Dann ist "Mina" die neue Kontaktperson dieses Auftrages

  @javascript
  Szenario: Anzeige der Bestellungen einer persönlichen Bestellung
    Angenommen ich bin Pius
    Und es existiert eine persönliche Bestellung
    Und ich befinde mich in dieser Bestellung
    Dann ist in der Bestellung der Name des Benutzers aufgeführt
    Und ich sehe keine Kontatkperson
