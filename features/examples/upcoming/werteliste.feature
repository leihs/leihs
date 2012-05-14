# language: de

Funktionalität: Werteliste

  Um eine konforme Werteliste aushändigen zu können
  möchte ich als Verleiher
  das mir das System für eine Auswahl eine Werteliste zur verfügung stellen kann

  Grundlage:
    Angenommen man ist "Pius"
    Und man öffnet eine Werteliste

  # https://www.pivotaltracker.com/story/show/26061363
  Szenario: Laufende Nummern
    Dann gibt es für jede Zeile eine laufende Nummer oder eine Spanne von laufenden Nummern (X/Y)
     Und die Anzahl der Gegenstände bestimt die Spanne der laufenden Nummern 

  # https://www.pivotaltracker.com/story/show/26061363
  Szenario: Format der Laufenden Nummern
    Angenommen die folgenden Zeilen sind im Vertrag:
    | inventarnummer | gegenstand            |
    | ABC123         | Mikrofon Sony Typ XYZ |
    | ABC124         | Mikrofon Sony Typ XYZ |
    | ABC125         | Monitor Sony Typ ABC  |
    | ABC126         | Monitor Sony Typ ABC  |
    | ABC127         | Stativ Manfrotto XYZ  |
    | ABC128         | Akkleuchte Photon Beard |
    Dann sehe ich in der Werteliste folgende Nummerierung:
    | position | inventarnummern | gegenstand               | stückzahl |
    | 1/2      | ABC123, ABC124  | Mikrofon Sony Typ XYZ    |         2 |
    | 3/4      | ABC125, ABC126  | Monitor Sony Typ ABC     |         2 |
    | 5        | ABC127          | Stativ Manfrotto XYZ     |         1 |
    | 6        | ABC128          | Akkuleuchte Photon Beard |         1 |
