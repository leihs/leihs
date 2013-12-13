# language: de

Funktionalität: Brotkrumennavigation

  Um mich schnell durch die Applikation bewegen zu können
  möchte ich als Ausleiher
  die möglichkeit haben schnell von A nach Z zu kommen

  Szenario: Brotkrumennavigation
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Dann sehe ich die Brotkrumennavigation

  Szenario: Home-Button der Brotkrumennavigation
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Und ich sehe die Brotkrumennavigation
    Dann beinhaltet diese immer an erster Stelle das Übersichtsbutton
    Und dieser führt mich immer zur Seite der Hauptkategorien

  Szenario: Hauptkategorie auswählen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Wenn ich eine Hauptkategorie wähle
    Dann öffnet diese Kategorie
    Und die Kategorie ist das zweite und letzte Element der Brotkrumennavigation

  @javascript
  Szenario: Unterkategorie auswählen
    Angenommen man ist "Normin"
    Und man befindet sich auf der Seite der Hauptkategorien
    Wenn ich eine Unterkategorie wähle
    Dann öffnet diese Kategorie
    Und die Kategorie ist das zweite und letzte Element der Brotkrumennavigation

