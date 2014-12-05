# language: de

Funktionalität: Benutzer verwalten 

  @javascript @personas
  Szenariogrundriss: Sperrfunktion für Benutzer und Delegation
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und man editiert einen <Benutzertyp>
    Und man nutzt die Sperrfunktion
    Dann muss man den Grund der Sperrung eingeben
    Und sofern der <Benutzertyp> gesperrt ist, kann man die Sperrung aufheben
    Beispiele:
      | Benutzertyp |
      | Benutzer    |
      | Delegation  |

  @upcoming @personas
  Szenario: Elemente der Editieransicht
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und man editiert einen Benutzer
    Dann sieht man als Titel den Vornamen und Namen des Benutzers, sofern bereits vorhanden
    Dann sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:
    Dann sieht man die Sperrfunktion für diesen Benutzer
    Und sofern dieser Benutzer gesperrt ist, sieht man Grund und Dauer der Sperrung
    Dann sieht man die folgenden Daten des Benutzers in der folgenden Reihenfolge:
    |en         |de           |
    |Last name  |Name         |
    |First name |Vorname      |
    |Address    |Strasse      |
    |Zip        |PLZ          |
    |City       |Ort          |
    |Country    |Land         |
    |Phone      |Telefonnummer|
    |E-Mail     |E-Mail-Adresse|
    Und man kann die Informationen ändern, sofern es sich um einen externen Benutzer handelt
    Und man kann die Informationen nicht verändern, sofern es sich um einen Benutzer handelt, der über ein externes Authentifizierungssystem eingerichtet wurde
    Und man sieht die Rollen des Benutzers und kann diese entsprechend seiner Rolle verändern
    Und man kann die vorgenommenen Änderungen abspeichern

  @personas
  Szenario: Als Administrator einen anderen Benutzer Administrator machen
    Angenommen ich bin Gino
    Und man befindet sich auf der Editierseite eines Benutzers, der kein Administrator ist und der Zugriffe auf Inventarpools hat
    Wenn man diesen Benutzer die Rolle Administrator zuweist
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und hat dieser Benutzer die Rolle Administrator
    Und alle andere Zugriffe auf Inventarpools bleiben beibehalten

  @personas
  Szenario: Als Administrator einem anderen Benutzer die Rolle Administrator wegnehmen
    Angenommen ich bin Gino
    Und man befindet sich auf der Editierseite eines Benutzers, der ein Administrator ist und der Zugriffe auf Inventarpools hat
    Wenn man diesem Benutzer die Rolle Administrator wegnimmt
    Und ich speichere
    Dann hat dieser Benutzer die Rolle Administrator nicht mehr
    Und alle andere Zugriffe auf Inventarpools bleiben beibehalten

  @personas
  Szenariogrundriss: Als Ausleihe- oder Inventar-Verwalter hat man kein Zugriff auf die Administrator-User-Pfade
    Angenommen ich bin <Person>
    Wenn man versucht auf die Administrator Benutzererstellenansicht zu gehen
    Dann gelangt man auf diese Seite nicht
    Wenn man versucht auf die Administrator Benutzereditieransicht zu gehen
    Dann gelangt man auf diese Seite nicht
    Beispiele:
      | Person |
      | Pius   |
      | Mike   |

  @javascript @personas
  Szenario: Neuen Benutzer im Geräterpark als Ausleihe-Verwalter hinzufügen
    Angenommen ich bin Pius
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access |
      | Customer  |
      | Group manager  |
      | Lending manager  |
    Und eine der folgenden Rollen auswählt
      | tab                | role              |
      | Kunde              | customer          |
      | Gruppen-Verwalter  | group_manager   |
      | Ausleihe-Verwalter | lending_manager   |
    Und man teilt mehrere Gruppen zu
    Und ich speichere
    Dann ist der Benutzer mit all den Informationen gespeichert

  @personas
  Szenario: Als Administrator neuen Benutzer erstellen
    Angenommen ich bin Gino
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Wenn man von hier auf die Benutzererstellungsseite geht
    Und den Nachnamen eingibt
    Und den Vornahmen eingibt
    Und die Email-Addresse eingibt
    Und man gibt die Login-Daten ein
    Und ich speichere
    Dann wird man auf die Benutzerliste ausserhalb der Inventarpools umgeleitet
    Und man sieht eine Bestätigungsmeldung
    Und der neue Benutzer wurde erstellt
    Und er hat keine Zugriffe auf Inventarpools und ist kein Administrator

  @personas
  Szenario: Auflistung der Inventarpools eines Benutzers
    Angenommen ich bin Ramon
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man einen Benutzer mit Zugriffsrechten editiert
    Dann werden die ihm zugeteilt Geräteparks mit entsprechender Rolle aufgelistet

  @javascript @browser @personas
  Szenario: Voraussetzungen fürs Löschen eines Benutzers im Gerätepark
    Angenommen ich bin Ramon
    Und man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann sehe ich eine Fehlermeldung
    Und der Benutzer ist nicht gelöscht

  @personas
  Szenario: Alphabetische Sortierung der Benutzer ausserhalb vom Inventarpool
    Angenommen ich bin Gino
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools

  @personas
  Szenario: Zugriff entfernen als Ausleihe-Verwalter
    Angenommen ich bin Pius
    Und man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat und keine Gegenstände hat
    Wenn man den Zugriff entfernt
    Und ich speichere
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool

  @javascript @personas
  Szenario: Benutzer im Geräterpark als Administrator löschen
    Angenommen ich bin Gino
    Und man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann wurde der Benutzer aus der Liste gelöscht
    Und der Benutzer ist gelöscht

  @personas
  Szenario: Zugriff entfernen als Administrator
    Angenommen ich bin Gino
    Und man editiert einen Benutzer der Zugriff auf ein Inventarpool hat und keine Gegenstände hat
    Wenn man den Zugriff entfernt
    Und ich speichere
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool

  @personas
  Szenario: Startseite setzen
    Angenommen ich bin Pius
    Und man befindet sich auf der Liste der Benutzer
    Wenn man die Startseite setzt
    Dann ist die Liste der Benutzer die Startseite

  @javascript @personas @browser
  Szenario: Elemente der Benutzeradministration
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Dann findet man die Benutzeradministration im Bereich "Administration" unter "Benutzer"
    Dann sieht man eine Liste aller Benutzer
    Und man kann filtern nach den folgenden Eigenschaften: gesperrt
    Und man kann filtern nach den folgenden Rollen:
      | tab                | role               |
      | Kunde              | customers          |
      | Ausleihe-Verwalter | lending_managers   |
      | Inventar-Verwalter | inventory_managers |
    Und man kann für jeden Benutzer die Editieransicht aufrufen

  @javascript @personas
  Szenario: Darstellung eines Benutzers in Listen mit zugeteilter Rolle
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und ein Benutzer mit zugeteilter Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
      |attr |
      |Vorname Name|
      |Telefonnummer|
      |Rolle|

  @javascript @personas
  Szenario: Darstellung eines Benutzers in Listen ohne zugeteilte Rolle
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und ein Benutzer ohne zugeteilte Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
      |attr |
      |Vorname Name|
      |Telefonnummer|
      |Rolle|

  @javascript @personas
  Szenario: Darstellung eines Benutzers in Listen mit zugeteilter Rolle und Status gesperrt
    Angenommen man ist Inventar-Verwalter oder Ausleihe-Verwalter
    Und ein gesperrter Benutzer mit zugeteilter Rolle erscheint in einer Benutzerliste
    Dann sieht man folgende Informationen in folgender Reihenfolge:
      |attr |
      |Vorname Name|
      |Telefonnummer|
      |Rolle|
      |Sperr-Status 'Gesperrt bis dd.mm.yyyy'|

  # English: lending manager
  @personas
  Szenario: Benutzerolle "Ausleihe-Verwalter"
    Angenommen man ist Ausleihe-Verwalter
    Wenn man im Inventar Bereich ist
    Dann kann man neue Gegenstände erstellen
    Und diese Gegenstände ausschliesslich nicht inventarrelevant sind
    Und man kann Optionen erstellen
    Und man kann neue Benutzer erstellen und für die Ausleihe sperren
    Und man kann nicht inventarrelevante Gegenstände ausmustern, sofern man deren Besitzer ist

  # English: inventory manager
  @personas
  Szenario: Benutzerolle "Inventar-Verwalter"
    Angenommen man ist Inventar-Verwalter
    Dann kann man neue Modelle erstellen
    Und kann man neue Gegenstände erstellen
    Und diese Gegenstände können inventarrelevant sein
    Und man kann sie einem anderen Gerätepark als Besitzer zuweisen
    Und man kann Gegenstände ausmustern, sofern man deren Besitzer ist
    Und man kann Ausmusterungen wieder zurücknehmen, sofern man Besitzer der jeweiligen Gegenstände ist
    Und man kann die Arbeitstage und Ferientage seines Geräteparks anpassen
    Und man kann Benutzern die folgende Rollen zuweisen und wegnehmen, wobei diese immer auf den Gerätepark bezogen ist, für den auch der Verwalter berechtigt ist
    | role                |
    | Kein Zugriff        |
    | Kunde               |
    | Gruppen-Verwalter   |
    | Ausleihe-Verwalter  |
    | Inventar-Verwalter  |
    Und man kann alles, was ein Ausleihe-Verwalter kann
    Wenn man keine verantwortliche Abteilung auswählt
    Dann ist die Verantwortliche Abteilung gleich wie der Besitzer

  @personas
  Szenario: Zugriff entfernen als Inventar-Verwalter
    Angenommen ich bin Mike
    Und man editiert einen Benutzer der Zugriff auf das aktuelle Inventarpool hat und keine Gegenstände hat
    Wenn man den Zugriff entfernt
    Und ich speichere
    Dann hat der Benutzer keinen Zugriff auf das Inventarpool

  @personas
  Szenariogrundriss: Zugriff entfernen für einen Benutzer mit offenen Vertrag
    Angenommen ich bin <Persona>
    Und es existiert ein Vertrag mit Status "<Vertragsstatus>" für einen Benutzer mit sonst keinem anderen Verträgen
    Wenn man den Benutzer für diesen Vertrag editiert
    Dann hat dieser Benutzer Zugriff auf das aktuelle Inventarpool
    Wenn man den Zugriff entfernt
    Und ich speichere
    Dann erhalte ich die Fehlermeldung "<Fehlermeldung>"
    Beispiele:
      | Persona | Vertragsstatus | Fehlermeldung                          |
      | Mike    | abgeschickt    | Hat momentan offene Bestellungen       |
      | Pius    | abgeschickt    | Hat momentan offene Bestellungen       |
      | Mike    | genehmigt      | Hat momentan offene Bestellungen       |
      | Pius    | genehmigt      | Hat momentan offene Bestellungen       |
      | Mike    | unterschrieben | Hat momentan Gegenstände zurückzugeben |
      | Pius    | unterschrieben | Hat momentan Gegenstände zurückzugeben |

   @upcoming
  Szenario: Gruppenzuteilung in Benutzeransicht hinzufügen/entfernen
    Angenommen ich bin Pius
    Und man editiert einen Benutzer
    Dann kann man Gruppen über eine Autocomplete-Liste hinzufügen
    Und kann Gruppen entfernen
    Und speichert den Benutzer
    Dann ist die Gruppenzugehörigkeit gespeichert 

  @javascript @personas
  Szenario: Neuen Benutzer im Geräterpark als Inventar-Verwalter hinzufügen
    Angenommen ich bin Mike
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | Adresse        |
      | PLZ            |
      | Ort            |
      | Land           |
      | Telefon        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    Und eine der folgenden Rollen auswählt
    | tab                | role                |
    | Kunde              | customer            |
    | Gruppen-Verwalter  | group_manager       |
    | Ausleihe-Verwalter | lending_manager     |
    | Inventar-Verwalter | inventory_manager   |
    Und man teilt mehrere Gruppen zu
    Und ich speichere
    Dann ist der Benutzer mit all den Informationen gespeichert

  @personas
  Szenario: Zugriff auf Ausleihe-Verwalter ändern als Ausleihe-Verwalter
    Angenommen ich bin Pius
    Und man editiert einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
    Wenn man den Zugriff auf "Ausleihe-Verwalter" ändert
    Und ich speichere
    Dann hat der Benutzer die Rolle Ausleihe-Verwalter

  @personas
  Szenario: Zugriff auf Kunde ändern als Ausleihe-Verwalter
    Angenommen ich bin Pius
    Und man editiert einen Benutzer der Ausleihe-Verwalter ist
    Wenn man den Zugriff auf "Kunde" ändert
    Und ich speichere
    Dann hat der Benutzer die Rolle Kunde

  @personas
  Szenario: Zugriff ändern als Inventar-Verwalter
    Angenommen ich bin Mike
    Und man editiert einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    Wenn man den Zugriff auf "Inventar-Verwalter" ändert
    Und ich speichere
    Dann hat der Benutzer die Rolle Inventar-Verwalter

  @personas
  Szenario: Zugriff auf ein Inventarpool gewährleisten als Inventar-Verwalter
    Angenommen ich bin Mike
    Und man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat
    Wenn man den Zugriff auf "Kunde" ändert
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und hat der Benutzer die Rolle Kunde

  @personas
  Szenario: Zugriff ändern als Administrator
    Angenommen ich bin Gino
    Und man editiert in irgendeinem Inventarpool einen Benutzer der Kunde ist
    Dann man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    Wenn man den Zugriff auf "Inventar-Verwalter" ändert
    Und ich speichere
    Dann hat der Benutzer die Rolle Inventar-Verwalter

  @javascript @browser @personas
  Szenario: Voraussetzungen fürs Löschen eines Benutzers
    Angenommen ich bin Ramon
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man sucht sich je einen Benutzer mit Zugriffsrechten, Bestellungen und Verträgen aus
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann sehe ich eine Fehlermeldung
    Und der Benutzer ist nicht gelöscht

  @javascript @personas
  Szenario: Alphabetische Sortierung der Benutzer innerhalb vom Inventarpool
    Angenommen ich bin Gino
    Und man befindet sich auf der Benutzerliste im beliebigen Inventarpool
    Dann sind die Benutzer nach ihrem Vornamen alphabetisch sortiert

  @personas
  Szenario: Benutzer ohne Zugriff im Inventarpool editieren ohne ihm dabei Zugriff zu gewährleisten
    Angenommen ich bin Pius
    Und man editiert einen Benutzer der kein Zugriff auf das aktuelle Inventarpool hat
    Wenn man ändert die Email
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und die neue Email des Benutzers wurde gespeichert
    Und der Benutzer hat nach wie vor keinen Zugriff auf das aktuelle Inventarpool

  @javascript @personas
  Szenario: Neuen Benutzer im Geräterpark als Administrator hinzufügen
    Angenommen ich bin Gino
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und die folgenden Informationen eingibt
      | Nachname       |
      | Vorname        |
      | E-Mail         |
    Und man gibt die Login-Daten ein
    Und man gibt eine Badge-Id ein
    Und man hat nur die folgenden Rollen zur Auswahl
      | No access          |
      | Customer           |
      | Group manager      |
      | Lending manager    |
      | Inventory manager  |
    Und eine der folgenden Rollen auswählt
      | tab                | role                |
      | Kunde              | customer            |
      | Gruppen-Verwalter  | group_manager       |
      | Ausleihe-Verwalter | lending_manager     |
      | Inventar-Verwalter | inventory_manager   |
    Und man teilt mehrere Gruppen zu
    Und ich speichere
    Dann ist der Benutzer mit all den Informationen gespeichert

  @personas
  Szenariogrundriss: Neuen Benutzer hinzufügen - ohne Eingabe der Pflichtfelder
    Angenommen ich bin Pius
    Wenn man in der Benutzeransicht ist
    Und man einen Benutzer hinzufügt
    Und alle Pflichtfelder sind sichtbar und abgefüllt
    Wenn man ein <Pflichtfeld> nicht eingegeben hat
    Und ich speichere
    Dann sehe ich eine Fehlermeldung
    Beispiele:
      | Pflichtfeld |
      | Nachname    |
      | Vorname     |
      | E-Mail      |

  @personas
  Szenario: Benutzer den Zugriff auf ein Inventarpool reaktivieren
    Angenommen ich bin Mike
    Und man editiert einen Benutzer der mal einen Zugriff auf das aktuelle Inventarpool hatte
    Wenn man den Zugriff auf "Kunde" ändert
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und hat der Benutzer die Rolle Kunde

  @javascript @personas
  Szenario: Benutzer als Administrator löschen
    Angenommen ich bin Gino
    Und man befindet sich auf der Benutzerliste ausserhalb der Inventarpools
    Und man sucht sich einen Benutzer ohne Zugriffsrechte, Bestellungen und Verträge aus
    Wenn ich diesen Benutzer aus der Liste lösche
    Dann wurde der Benutzer aus der Liste gelöscht
    Und der Benutzer ist gelöscht

  @personas @upcoming
  Szenario: Startseite zurücksetzen
    Angenommen ich bin Pius
    Und man hat eine Startseite gesetzt
    Wenn man seine Startseite zurücksetzt
    Dann ist ist keine Startseite gesetzt
    Wenn man auf das Logo klickt
    Dann landet man auf der Tagesansicht als Standard-Startseite
