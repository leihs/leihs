# language: de

Funktionalität: Automatischer E-Mail versand
  Grundlage:
    Angenommen Das System ist für den Mailversand im Testmodus konfiguriert
    Und ich bin Normin

  Szenario: Automatische Rückgabeerinnerung
    Angenommen ich habe eine nicht verspätete Rückgabe
    Dann wird mir einen Tag vor der Rückgabe eine Erinnerungs E-Mail zugeschickt
    
  Szenario: Automatische Erinerung bei verpasster Rückgabe
    Angenommen ich habe eine verspätete Rückgabe
    Dann erhalte ich einen Tag nach Rückgabedatum eine Erinnerungs E-Mail zugeschickt
    Und für jeden weiteren Tag erhalte ich erneut eine Erinnerungs E-Mail zugeschickt
    
