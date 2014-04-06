# language: de

Funktionalität: Benutzer verwalten 

  Grundlage:
    Angenommen Personas existieren
  
  Szenario: Als Administrator einen anderen Benutzer Administrator machen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Editierseite eines Benutzers, der kein Administrator ist und der Zugriffe auf Inventarpools hat
    Wenn man diesen Benutzer die Rolle Administrator zuweist
    Und ich speichere
    Dann sieht man die Erfolgsbestätigung
    Und hat dieser Benutzer die Rolle Administrator
    Und alle andere Zugriffe auf Inventarpools bleiben beibehalten

  Szenario: Als Administrator einem anderen Benutzer die Rolle Administrator wegnehmen
    Angenommen man ist "Gino"
    Und man befindet sich auf der Editierseite eines Benutzers, der ein Administrator ist und der Zugriffe auf Inventarpools hat
    Wenn man diesem Benutzer die Rolle Administrator wegnimmt
    Und ich speichere
    Dann hat dieser Benutzer die Rolle Administrator nicht mehr
    Und alle andere Zugriffe auf Inventarpools bleiben beibehalten

  Szenariogrundriss: Als Ausleihe- oder Inventar-Verwalter hat man kein Zugriff auf die Administrator-User-Pfade
    Angenommen man ist "<Person>"
    Wenn man versucht auf die Administrator Benutzererstellenansicht zu gehen
    Dann gelangt man auf diese Seite nicht
    Wenn man versucht auf die Administrator Benutzereditieransicht zu gehen
    Dann gelangt man auf diese Seite nicht

    Beispiele:
      | Person |
      | Pius   |
      | Mike   |