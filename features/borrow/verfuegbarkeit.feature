  Szenario: Überbuchung durch Ausleih-Manager
    Angenommen man ist "Normin"
    Wenn ich ein Modell der Bestellung hinzufüge
    Angenommen man ist "Pius"
    Wenn ich dasselbe Modell einer Bestellung hinzufüge
    Und die maximale Anzahl der Gegenstände überschritten ist
    Angenommen man ist "Normin"
    Wenn ich die Bestellung abschliesse
    Dann wird die Bestellung nicht abgeschlossen
    Und ich erhalte eine Fehlermeldung

  Szenario: Blockieren der Modelle
    Angenommen man ist "Normin"
    Und ich habe eine offene Bestellung mit Modellen
    Wenn ich eine Aktivität ausführe
    Dann bleiben die Modelle in der Bestellung blockiert
    
  Szenario: Freigabe der Modelle
    Angenommen man ist "Normin"
    Und ich habe eine offene Bestellung mit Modellen
    Wenn ich länger als 30 Minuten keine Aktivität ausgeführt habe
    Dann werden die Modelle meiner Bestellung freigegeben
  
  Szenario: Erneutes Blockieren nach Inaktivität
    Angenommen man ist "Normin"
    Und man ist inaktiv
    Wenn man eine Aktivität ausführt
    Und alle Modelle verfügbar sind
    Dann kann man sein Prozess fortsetzen
    Und die Modelle werden blockiert
    
  Szenario: Modelle nach langer Inaktivität nicht mehr verfügbar
    Angenommen man ist "Normin"
    Und man ist inaktiv
    Wenn man eine Aktivität ausführt
    Und ein Modell ist nicht verfügbar
    Dann werde ich auf die Timeout Page geleitet
    
    
    
    
    
    
