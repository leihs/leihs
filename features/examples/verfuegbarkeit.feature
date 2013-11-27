# language: de

Funktionalität: Verfügbarkeit

  Grundlage:
    Angenommen Personas existieren
   

    Szenario: Zuweisung einer Bestellungs-Zeile für ein Nicht-Gruppenmitglied
    	Angenommen der Kunde ist nicht in der Gruppe "CAST"
    	Und es gibt ein Modell, welches folgende Partitionen hat:
    	|gruppe   |anzahl|
    	|CAST     |3|
    	|Allgemein|5|
    	Wenn dieser Kunde das Modell bestellen möchte
    	Dann ist dieses Modell für den Kunden "5" Mal verfügbar
		Dann ist dieses Modell für den Kunden nicht "8" Mal verfügbar

    Szenario: Zuweisung einer Bestellungs-Zeile für ein Gruppenmitglied
    	Angenommen der Kunde ist in der Gruppe "CAST"
    	Und es gibt ein Modell, welches folgende Partitionen hat:
    	|gruppe   |anzahl|
    	|CAST     |3|
    	|Allgemein|5|
    	Wenn dieser Kunde das Modell bestellen möchte
    	Dann ist dieses Modell für den Kunden "8" Mal verfügbar

    Szenario: Prioritäten der Gruppen bei der Zuweisung
    	Wenn ein Modell in mehreren Gruppen verfügbar ist
    	Dann wird zuletzt die Gruppe "Allgemein" belastet
    	
    Szenario: Keine Verfügbarkeitsberechnung bei Optionen
    	Wenn eine Rücknahme nur Optionen enthält
    	Dann wird für diese Optionen keine Verfügbarkeit berechnet
