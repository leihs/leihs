# language: de

Funktionalität: Automatischer E-Mail versand

  Szenario: Automatische Rückgabeerinnerung
    Angenommen man ist "Normin"
    Und ich habe eine nicht verspätete Rückgabe
    Dann wird mir einen Tag vor der Rückgabe eine Erinnerungs E-Mail zugeschickt
    
  Szenario: Automatische Erinerung bei verpasster Rückgabe
    Angenommen man ist "Normin"
    Und ich habe eine verspätete Rückgabe
    Dann erhalte ich einen Tag nach Rückgabedatum eine Erinnerungs E-Mail zugeschickt
    Und für jeden weiteren Tag erhalte ich erneut eine Erinnerungs E-Mail zugeschickt
    
