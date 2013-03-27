# language: de

Funktionalität: Modell mit Paketen erstellen

  Szenario: Modell mit Paketzuteilung erstellen
    Wenn Ich ein Modell erstelle 
    Und ich mindestens die Pflichtfelder ausfülle
    Und Ich eines oder mehrere Pakete hinzufüge
    Und ich diesem Paket eines oder mehrere Gegenstände hinzufügen
    Und ich das Modell speichere
    Dann ist das Modell erstellt und die Pakete und dessen zugeteilten Gegenstände gespeichert
    Und den Paketen wird ein Inventarcode zugewiesen

  Szenario: Modell mit bereits vorhandenen Gegenständen kann kein Paket zugewiesen werden
    Wenn Ich ein Modell editiere, welches bereits Gegenstände hat
    Dann kann ich diesem Modell keine Pakete mehr zuweisen

  Szenario: Paketeigenschaften abfüllen
    Wenn ich dem Modell ein Paket hinzufüge
    Dann werden die folgenden Felder angezeigt
    | Zustand | 
    | Vollständigkeit | 
    | Ausleihbar | 
    | Braucht Ausleihbewilligung | 
    | Inventarrelevant | 
    | Besitzer | 
    | Verantwortliche Abteilung | 
    | Verantwortliche Person | 
    | Benutzer/Verwendung | 
    | Umzug | 
    | Zielraum | 
    | Ankunftsdatum | 
    | Ankunftsdatum | 
    | Ankunftsdatum | 
    | Name | 
    | Notiz | 
    | Gebäude | 
    | Raum |  
    | Gestell | 
    | Anschaffungswert |

  Szenario: Paket löschen
    Wenn das Paket zurzeit nicht ausgeliehen ist 
    Dann kann ich das Paket löschen und die Gegenstände sind nicht mehr dem Paket zugeteilt

  Szenario: Pakete nicht ohne Gegenstände erstellen
    Wenn ich einem Modell ein Paket hinzufüge
    Dann kann ich dieses Paket nur speichern, wenn dem Paket auch Gegenstände zugeteilt sind

  Szenario: Einzelner Gegenstand aus Paket entfernen
    Wenn ich ein Paket editiere
    Dann kann ich einen Gegenstand aus dem Paket entfernen
    Und dieser Gegenstand ist nicht mehr dem Paket zugeteilt




