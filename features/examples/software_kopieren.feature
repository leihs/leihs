# language: de

Funktionalität: Software kopieren

  Grundlage:
    Angenommen ich bin Mike

  @upcoming
  Szenario: Software kopieren
    Angenommen es existiert eine Software-Lizenz
    Wenn ich eine bestehende Software-Lizenz kopiere
    Dann wird die Editieransicht der neuen Software-Lizenz geöffnet
    Und der Titel heisst "Neue Software-Lizenz erstellen"
    Und der Speichern-Button heisst "Lizenz speichern"
    Und ein neuer Inventarcode wird angezeigt
    Und die folgenden Felder werden von der kopierten Lizenz übernommen
    | Software   |
    | Bezug  |
    | Besitzer |
    | Verantwortliche Abteilung |
    | Rechnungsdatum |
    | Anschaffungswert |
    | Lieferant |
    | Beschafft durch |
    | Notiz |
    | Aktivierungstyp |
    | Lizenztyp |
    | Anzahl |
    | Betriebssystem |
    | Installation |
    | Lizenzablaufdatum |
    | Maintenance-Vertrag |
    | Maintenance-Ablaufdatum |
    Wenn ich die Lizenz speichere
    Dann ist die Lizenz mit den angegebenen Informationen gespeichert

  @upcoming
  Szenario: Wo kann Software kopiert werden
    Angenommen es existiert eine Software-Lizenz
    Wenn ich mich in der Inventarliste befinde
    Dann kann ich die bestehende Software kopieren
    Wenn ich mich in der Editieransicht einer Sofware-Lizenz befinde
    Dann kann ich die bestehende Software speichern und kopieren




