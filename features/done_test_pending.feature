Feature: Resolved Wishes and Bug Reports by our Users that are pending a Test

Background: moving resolved todo's here, which we did not have the time to write tests for

Scenario: Inventory Manager should be able to add own ("Besitzer" and not "Verantwortlicher"!) Items to Package
  Given reported by Mike on 12.July 2010
  Given resolved by tpo on 12.July
  Given test pending

Scenario: The inventory relevant flag should be 'no' by default and 'yes' for managers with level > 3 who should be also able to set it
# BUG: A manager of level 2 should not be able to create items flagged "inventory relevant". The default must be "not inventory relevant"
  Given reported by Mike on 12.July 2010
  Given resolved by tpo on 13.July
  Given test pending

Scenario: Wenn jemand gesperrt wird, dann sollte man angeben können warum
  Given reported by Claudio on 6.July 2010
  Given resolved by sellittf in ancient times
  Given test pending

Scenario: Verträge -> User -> Werteverzeichnis ausdrucken -> Seriennummer reinnehmen
  Given reported by Claudio on 22.June 2010
  Given resolved by rca on 20. July 2010
  Given automated test impossible? Manual testing was done.

Scenario: Optionen -> sollten Wert haben
  Given reported by Claudio on 22.June 2010
  Given resolved by rca on 21. July 2010
  Given automated test not useful? Just a unit test?

Scenario: Allow attaching any kind of binary file to a model, not just images.
  Given reported by Mike ages ago, repeated 14.07.2010
  Given resolved by rca on 23. July 2010
  Given test pending

Scenario: i.e. wenn Location ID, Inventory Pool eines Pakets ändern, dann müssen die entsprechenden Eigenschaften aller Gegenstände ändern 
  Given reported by Claudio,Mike on 6.July 2010 
  Given resolved by sellittf on 26.July 2010
  Given test pending
 
Scenario: wenn Gegenstand einem Paket hinzugefügt wird, dann nimmt es seine Eigenschaftern Location und Inventory Pool an 
  Given reported by Claudio,Mike on 6.July 2010 
  Given resolved by sellittf on 26.July 2010
  Given test pending

Scenario: wenn Gegenstand zu einem anderen Paket wechselt, dann nimmt es die Eigenschaftern Location und Inventory Pool des neuen Pakets an 
  Given reported by Claudio,Mike on 6.July 2010 
  Given resolved by sellittf on 26.July 2010
  Given test pending

