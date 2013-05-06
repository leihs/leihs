# language: de

Funktionalität: Geräteparks administrieren

  Um die Geräteparks zu administrieren
  möchte ich als Administrator
  die nötigen Funktionalitäten

  Szenario: Den ersten Gerätepark erstellen
    Angenommen ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle
    Und ich Name und Kurzname eingebe
    Und ich speichere
    Dann ist der Gerätepark gespeichert
    Und eine Bestätigung wird angezeigt
    Und ich sehe die Geräteparkliste

  Szenario: Pflichtfelder beim erstmaligen Erstellen eines Geräteparks
    Angenommen ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen neuen Gerätepark erstelle
    Und ich Name oder Kurzname nicht eingebe
    Dann wird mir eine Fehlermeldung angezeigt
    Und der Gerätepark wird nicht erstellt

  Szenario: Gerätepark ändern
    Angenommen ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark ändere
    Und ich Name und Kurzname ändere
    Und ich den Gerätepark speichere
    Dann ist der Gerätepark und die eingegebenen Informationen gespeichert

  Szenario: Gerätepark löschen
    Angenommen ich bin Ramon
    Wenn ich im Admin-Bereich unter dem Reiter Geräteparks einen bestehenden Gerätepark lösche
    Dann wird der Gerätepark gelöscht
    Und ich sehe die Geräteparkliste
    Und ich sehe eine Bestätigung


