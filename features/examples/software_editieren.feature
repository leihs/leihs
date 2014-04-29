# language: de

Funktionalität: Software erfassen

Grundlage:
Angenommen Personas existieren
Und man ist "Mike"

 @javascript
Szenario: Software-Produkt editieren
Wenn ich eine Software editiere
Dann kann ich die folgenden Details editieren
| Feld | Wert |
| Produkt | Test Software I |
| Version | Test Version I |
| Hersteller | Neuer Hersteller |
| Betriebssystem | Mac OS |
| Installation | lokal |
| Hinweise | Installationslink beachten: http://wwww.dokuwiki.ch/neue_seite |
Wenn ich speichere
Dann ist die Software mit den geänderten Informationen gespeichert


@javascript
Szenario: Software-Lizenz editieren
Wenn ich eine bestehende Software-Lizenz editiere
Und ich ein anderes Produkt auswähle
Und ich eine andere Lizenznummer eingebe
Und ich eine andere Aktivierungsart wähle
Und ich eine andere Lizenzart wähle
Und ich den Wert "Ausleihbar" ändere
Aber ich kann die Inventarnummer nicht ändern
Wenn ich speichere
Dann sind die Informationen dieser Software-Lizenz gespeichert
