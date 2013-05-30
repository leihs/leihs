# language: de

Funktionalität: Geräteparks administrieren

  Um die Geräteparks zu administrieren
  möchte ich als Administrator
  die nötigen Funktionalitäten

  @javascript
  Szenario: Den ersten Gerätepark erstellen
    Angenommen persona "Gino" existing
    Und ich bin Gino
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle
    Und ich Name und Kurzname und Email eingebe
    Und ich speichere
    Dann ich sehe die Geräteparkliste
    Und eine Bestätigung wird angezeigt
    Und ist der Gerätepark gespeichert

  @javascript
  Szenariogrundriss: Pflichtfelder beim erstmaligen Erstellen eines Geräteparks
    Angenommen persona "Ramon" existing
    Und ich bin Ramon
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

  @javascript
  Szenario: Gerätepark ändern
    Angenommen persona "Ramon" existing
    Und ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark ändere
    Und ich Name und Kurzname und Email ändere
    Und ich speichere
    Dann ist der Gerätepark und die eingegebenen Informationen gespeichert

  @javascript
  Szenario: Gerätepark löschen
    Angenommen persona "Ramon" existing
    Und ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark lösche
    Und der Gerätepark wurde aus der Liste gelöscht
    Und der Gerätepark wurde aus der Datenbank gelöscht
