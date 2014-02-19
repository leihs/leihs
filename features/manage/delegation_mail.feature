# language: de

Funktionalität: Mailversand bei Delegationsbestellungen und -besuchen

    @upcoming
    Szenario: Handhabung der Genehmigungsmails
      Angenommen ich bin Pius
      Wenn ich eine Bestellung genehmige
      Und der Besteller ist eine Delegation
      Dann wird das Genehmigungsmail an den Besteller versendet
      Und das Genehmigungsmail wird nicht an den Delegationsverantwortlichen versendet
      
    @upcoming
    Szenario: Handhabung der Erinnerungsmails
      Angenommen ich bin Pius
      Wenn ich bei einer Rücknahme eine Erinnerung sende
      Und der Vertrag lautet auf eine Delegation
      Dann wird das Erinnerungsmail an den Abholenden versendet
      Und das Erinnerungsmail wird nicht an den Delegationsverantwortlichen versendet
      
    @upcoming
    Szenario: Mail an Delegation senden
      Angenommen ich bin Pius
      Wenn ich nach einer Delegation suche
      Und ich die Mailfunktion wähle
      Dann wird das Mail an den Delegationsverantwrotlichen verschickt
      
      
