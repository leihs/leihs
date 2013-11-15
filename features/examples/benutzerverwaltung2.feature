# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren

  @javascript
  Szenario: Darstellung eines Benutzers in Listen mit zugeteilter Rolle
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Angenommen ein Benutzer mit zugeteilter Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
    |attr |
    |Vorname Name|
    |Telefonnummer|
    |Rolle|

  @javascript
  Szenario: Darstellung eines Benutzers in Listen ohne zugeteilte Rolle
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Angenommen ein Benutzer ohne zugeteilte Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
    |attr |
    |Vorname Name|
    |Telefonnummer|
    |Rolle|

  @javascript
  Szenario: Darstellung eines Benutzers in Listen mit zugeteilter Rolle und Status gesperrt
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Angenommen ein gesperrter Benutzer mit zugeteilter Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
    |attr |
    |Vorname Name|
    |Telefonnummer|
    |Rolle|
    |Sperr-Status 'Gesperrt bis dd.mm.yyyy'|