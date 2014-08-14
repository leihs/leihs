# language: de

Funktionalität: Geräteparks administrieren

  Um die Geräteparks zu administrieren
  möchte ich als Administrator
  die nötigen Funktionalitäten

  @javascript @personas
  Szenario: Geräteparkauswahl
    Angenommen ich bin Gino
    Wenn ich in den Admin-Bereich wechsel
    Dann ich sehe die Geräteparkliste
    Wenn ich auf die Geraetepark-Auswahl klicke
    Dann sehe ich alle Geraeteparks
    Und die Geräteparkauswahl ist alphabetish sortiert

  @personas
  Szenario: Den ersten Gerätepark erstellen
    Angenommen ich bin Gino
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle
    Und ich Name und Kurzname und Email eingebe
    Und ich speichere
    Dann ich sehe die Geräteparkliste
    Und man sieht eine Bestätigungsmeldung
    Und ist der Gerätepark gespeichert

  @personas
  Szenariogrundriss: Pflichtfelder beim erstmaligen Erstellen eines Geräteparks
    Angenommen ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle
    Und ich <Pflichtfeld> nicht eingebe
    Und ich speichere
    Dann wird mir eine Fehlermeldung angezeigt
    Und der Gerätepark wird nicht erstellt

    Beispiele:
      | Pflichtfeld |
      | Name        |
      | Kurzname    |
      | E-Mail      |

  @personas
  Szenario: Gerätepark ändern
    Angenommen ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark ändere
    Und ich Name und Kurzname und Email ändere
    Und ich speichere
    Dann ist der Gerätepark und die eingegebenen Informationen gespeichert

  @javascript @personas
  Szenario: Gerätepark löschen
    Angenommen ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark lösche
    Und der Gerätepark wurde aus der Liste gelöscht
    Und der Gerätepark wurde aus der Datenbank gelöscht
