# language: de

Funktionalität: Ausmustern

  @javascript
  Szenariogrundriss: Ausmustern
    Angenommen ich bin Matti
    Und man sucht nach einem nicht ausgeliehenen <Objekt>
    Dann kann man diesen <Objekt> mit Angabe des Grundes erfolgreich ausmustern
    Und der gerade ausgemusterte <Objekt> verschwindet sofort aus der Inventarliste
    Beispiele:
      | Objekt     |
      | Gegenstand  |
      | Lizenz     |

  @javascript
  Szenario: Verhinderung von Ausmusterung eines ausgeliehenen Objektes
    Angenommen ich bin Mike
    Und man sucht nach einem ausgeliehenen <Objekt>
    Dann hat man keine Möglichkeit solchen <Objekt> auszumustern
    Beispiele:
      | Objekt     |
      | Gegenstand  |
      | Lizenz     |

  @javascript
  Szenario: Verhinderung von Ausmusterung eines Objektes bei dem ich nicht als Besitzer eingetragen bin
    Angenommen ich bin Matti
    Und man sucht nach einem <Objekt> bei dem ich nicht als Besitzer eingetragen bin
    Dann hat man keine Möglichkeit solchen <Objekt> auszumustern
    Beispiele:
      | Objekt     |
      | Gegenstand  |
      | Lizenz     |

  @javascript
  Szenario: Fehlermeldung bei der Ausmusterung ohne angabe eines Grundes
    Angenommen ich bin Matti
    Und man sucht nach einem nicht ausgeliehenen <Objekt>
    Und man gibt bei der Ausmusterung keinen Grund an
    Und der <Objekt> ist noch nicht Ausgemustert
    Beispiele:
      | Objekt     |
      | Gegenstand  |
      | Lizenz     |

  @javascript
  Szenario: Ausmusterung rückgangig machen
    Angenommen ich bin Mike
    Und man sucht nach einem ausgemusterten <Objekt>, wo man der Besitzer ist
    Und man befindet sich auf der Editierseite von diesem <Objekt>
    Wenn man die Ausmusterung bei diesem <Objekt> zurück setzt
    Und die Anschaffungskategorie ist ausgewählt
    Und ich speichere
    Dann wurde man auf die Inventarliste geleitet
    Und dieses <Objekt> ist nicht mehr ausgemustert
    Beispiele:
      | Objekt     |
      | Gegenstand  |
      | Lizenz     |


  Szenario: Ansichtseite von einem ausgemusterten Objekt für Verantwortlichen anzeigen
    Angenommen ich bin Mike
    Und man sucht nach einem ausgemusterten <Objekt>, wo man der Verantwortliche und nicht der Besitzer ist
    Dann man befindet sich auf der Editierseite von diesem <Objekt>
    Beispiele:
      | Objekt     |
      | Gegenstand  |
      | Lizenz     |
