# language: de

Funktionalität: Navigation

  @personas
  Szenario: Navigation für Gruppen-Verwalter
    Angenommen ich bin Andi
    Und man befindet sich im Verleih-Bereich
    Dann seh ich die Navigation
    Und die Navigation beinhaltet "Verleih"
    Und die Navigation beinhaltet "Ausleihen"
    Und die Navigation beinhaltet "Benutzer"

  @personas
  Szenario: Navigation für Gruppen-Verwalter in Verleih-Bereich
    Angenommen ich bin Andi
    Und man befindet sich im Verleih-Bereich
    Dann seh ich die Navigation
    Und die Navigation beinhaltet nur die Bestellungen
    Und man sieht die Gerätepark-Auswahl im Verwalten-Bereich

  @personas
  Szenario: Aufklappen der Geraeteparkauswahl und Wechsel des Geraeteparks
    Angenommen ich bin Mike
    Wenn ich auf die Geraetepark-Auswahl klicke
    Dann sehe ich alle Geraeteparks, zu denen ich Zugriff als Verwalter habe
    Wenn ich auf einen Geraetepark klicke
    Dann wechsle ich zu diesem Geraetepark

  @personas @javascript
  Szenario: Zuklappen der Geraeteparkauswahl
    Angenommen ich bin Mike
    Wenn ich auf die Geraetepark-Auswahl klicke
    Dann sehe ich alle Geraeteparks, zu denen ich Zugriff als Verwalter habe
    Wenn ich ausserhalb der Geraetepark-Auswahl klicke
    Dann schliesst sich die Geraetepark-Auswahl
    Wenn ich auf die Geraetepark-Auswahl klicke
    Dann sehe ich alle Geraeteparks, zu denen ich Zugriff als Verwalter habe
    Wenn ich erneut auf die Geraetepark-Auswahl klicke
    Dann schliesst sich die Geraetepark-Auswahl
