# language: de

Funktionalität: Verfügbarkeit

  Grundlage:
    Angenommen man ist "Normin"
    Und ich habe eine offene Bestellung mit Modellen
    Und die Bestellung Timeout ist 30 Minuten

  Szenario: Überbuchung durch Ausleih-Manager
    Wenn ich ein Modell der Bestellung hinzufüge
    Angenommen man ist "Pius"
    Wenn ich dasselbe Modell einer Bestellung hinzufüge
    Und die maximale Anzahl der Gegenstände überschritten ist
    Angenommen man ist "Normin"
    Wenn ich die Bestellübersicht öffne
    Und ich die Bestellung abschliesse
    Dann wird die Bestellung nicht abgeschlossen
    Und ich lande auf der Seite der Bestellübersicht
    Und ich erhalte eine Fehlermeldung

  Szenario: Blockieren der Modelle
    Wenn ich eine Aktivität ausführe
    Dann bleiben die Modelle in der Bestellung blockiert
    
  Szenario: Freigabe der Modelle
    Wenn ich länger als 30 Minuten keine Aktivität ausgeführt habe
    Dann werden die Modelle meiner Bestellung freigegeben
  
  Szenario: Erneutes Blockieren nach Inaktivität
    Angenommen ich länger als 30 Minuten keine Aktivität ausgeführt habe
    Und alle Modelle verfügbar sind
    Wenn ich eine Aktivität ausführe
    Dann kann man sein Prozess fortsetzen
    Und die Modelle werden blockiert

  Szenario: Modelle nach langer Inaktivität nicht mehr verfügbar
    Angenommen ein Modell ist nicht verfügbar
    Und ich länger als 30 Minuten keine Aktivität ausgeführt habe
    Wenn ich eine Aktivität ausführe
    Dann werde ich auf die Timeout Page geleitet
    
    
    
    
    
    
