# run as:
#   cucumber features/personas/generating_personas.feature
# get the generated dumps at:
#   features/personas/dumps/

Feature: Generating Personas

  @generating_personas
  Scenario: Deleting old Datasets
    Given no dump is existing

  @generating_personas
  Scenario: Genarating Minimal Dataset
    Given the minimal setup exists
    Then the minimal seed dump is generated

  @generating_personas
  Scenario: Genarating Dataset 1
    Given today is a random date
    And the minimal seed dump is loaded

    And the following users exist
      | firstname                 | lastname                 | email                    | language | address                                 |
      | Gino                      | #{Faker::Name.last_name} | gino@zhdk.ch             | en-GB    |                                         |
      | Ramon                     | #{Faker::Name.last_name} | ramon@zhdk.ch            | en-GB    |                                         |
      | Matti                     | #{Faker::Name.last_name} | matti@zhdk.ch            | en-GB    |                                         |
      | Mike                      | #{Faker::Name.last_name} | mike@zhdk.ch             | en-GB    |                                         |
      | Pius                      | #{Faker::Name.last_name} | pius@zhdk.ch             | en-GB    |                                         |
      | Normin                    | Normalo                  | normin@zhdk.ch           | en-GB    |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | lending_manager1@zhdk.ch | en-GB    |                                         |
      | Peter                     | Silie                    | peter@silie.com          | en-GB    |                                         |
      | Andi                      | #{Faker::Name.last_name} | andi@zhdk.ch             | en-GB    |                                         |
      | Mina                      | #{Faker::Name.last_name} | mina@zhdk.ch             | en-GB    |                                         |
      | Petra                     | #{Faker::Name.last_name} | petra@zhdk.ch            | en-GB    | #{Faker::Address.street_address + ", "} |
      | Julie                     | #{Faker::Name.last_name} | julie@zhdk.ch            |          |                                         |
      | Lisa                      | #{Faker::Name.last_name} | lisa@zhdk.ch             | en-GB    |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer1@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer2@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer3@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer4@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer5@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer6@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer7@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer8@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | customer9@zhdk.ch        |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | delegator1@zhdk.ch       |          |                                         |
      | #{Faker::Name.first_name} | #{Faker::Name.last_name} | delegated1@zhdk.ch       |          |                                         |

    And 1 user exists

    Then there are 25 users in total

    And the following inventory pools exist
      | name         | shortname | email      | description                                                             | contact_details                                     | contract_description | automatic_suspension |
      | A-Ausleihe   | A         | a@zhdk.ch  | Wichtige Hinweise...\n\nBitte die Gegenstände rechtzeitig zurückbringen | A Verleih  /  ZHdK\na@zh-dk.ch\n\n+41 00 00 00 00   | Gerät erhalten       | true                 |
      | IT-Ausleihe  | IT        | it@zhdk.ch | Bringt die Geräte bitte rechtzeitig zurück                              | IT Verleih  /  ZHdK\nit@zh-dk.ch\n\n+41 00 00 00 00 | Gerät erhalten       | true                 |
      | AV-Technik   | AV        | av@zhdk.ch | Bringt die Geräte bitte rechtzeitig zurück                              | AV Verleih  /  ZHdK\nav@zh-dk.ch\n\n+41 00 00 00 00 | Gerät erhalten       | false                |
      | DT deletable | DT        | it@zhdk.ch |                                                                         |                                                     | Gerät erhalten       | false                |

    Then there are 4 inventory pools in total

    And the following delegations exist
      | delegator user email | name         |
      | julie@zhdk.ch        | Delegation 1 |
      | mina@zhdk.ch         | Delegation 2 |
      | mina@zhdk.ch         | Delegation 3 |
      | mina@zhdk.ch         | Delegation 4 |
      | delegator1@zhdk.ch   | Delegation 5 |

    Then there are 5 delegations in total

    And the following delegations have following delegated users
      | delegation name | user email         |
      | Delegation 1    | mina@zhdk.ch       |
      | Delegation 2    | julie@zhdk.ch      |
      | Delegation 3    | julie@zhdk.ch      |
      | Delegation 4    | julie@zhdk.ch      |
      | Delegation 5    | delegated1@zhdk.ch |

    And the following access rights exist
      | user email               | delegation name | role              | inventory pool | deleted at        | suspended until | suspended reason         |
      | gino@zhdk.ch             |                 | admin             |                |                   |                 |                          |
      | ramon@zhdk.ch            |                 | admin             |                |                   |                 |                          |
      | ramon@zhdk.ch            |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | matti@zhdk.ch            |                 | inventory_manager | IT-Ausleihe    |                   |                 |                          |
      | mike@zhdk.ch             |                 | inventory_manager | A-Ausleihe     |                   |                 |                          |
      | mike@zhdk.ch             |                 | inventory_manager | DT deletable   |                   |                 |                          |
      | pius@zhdk.ch             |                 | lending_manager   | A-Ausleihe     |                   |                 |                          |
      | pius@zhdk.ch             |                 | lending_manager   | IT-Ausleihe    |                   |                 |                          |
      | lending_manager1@zhdk.ch |                 | lending_manager   | A-Ausleihe     |                   |                 |                          |
      | lending_manager1@zhdk.ch |                 | lending_manager   | IT-Ausleihe    |                   |                 |                          |
      | peter@silie.com          |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | normin@zhdk.ch           |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | normin@zhdk.ch           |                 | customer          | IT-Ausleihe    |                   |                 |                          |
      | normin@zhdk.ch           |                 | customer          | AV-Technik     |                   |                 |                          |
      | normin@zhdk.ch           |                 | customer          | DT deletable   | #{Date.yesterday} |                 |                          |
      | andi@zhdk.ch             |                 | group_manager     | A-Ausleihe     |                   |                 |                          |
      | andi@zhdk.ch             |                 | group_manager     | IT-Ausleihe    |                   |                 |                          |
      | andi@zhdk.ch             |                 | group_manager     | AV-Technik     |                   |                 |                          |
      | mina@zhdk.ch             |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | petra@zhdk.ch            |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | julie@zhdk.ch            |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | lisa@zhdk.ch             |                 | customer          | A-Ausleihe     |                   |                 |                          |
      |                          | Delegation 1    | customer          | A-Ausleihe     |                   |                 |                          |
      |                          | Delegation 2    | customer          | A-Ausleihe     |                   |                 |                          |
      |                          | Delegation 2    | customer          | IT-Ausleihe    |                   |                 |                          |
      |                          | Delegation 4    | customer          | A-Ausleihe     |                   |                 |                          |
      |                          | Delegation 4    | customer          |                |                   |                 |                          |
      |                          | Delegation 4    | customer          |                |                   |                 |                          |
      |                          | Delegation 5    | customer          | A-Ausleihe     |                   |                 |                          |
      | delegator1@zhdk.ch       |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | delegated1@zhdk.ch       |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer1@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer2@zhdk.ch        |                 | customer          | A-Ausleihe     |                   | #{Date.today}   | #{Faker::Lorem.sentence} |
      | customer3@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer4@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer5@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer6@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer7@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer8@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |
      | customer9@zhdk.ch        |                 | customer          | A-Ausleihe     |                   |                 |                          |

    And users with the following access rights exist
      | role            | inventory pool |
      | customer        | AV-Technik     |
      | lending_manager | A-Ausleihe     |
      | group_manager   | A-Ausleihe     |

    Then there are 43 access rights in total

    Then there are 6 inventory pools in total
    Then there are 6 workdays in total

    And the following workdays exist
      | inventory pool | monday | tuesday | wednesday | thursday | friday | saturday | sunday | reservation_advance_days | max_visits                  |
      | A-Ausleihe     | 1      | 1       | 1         | 1        | 1      | 0        | 0      | 0                        | {"1": 10, "2": 20, "3": 30} |

    Then there are 6 workdays in total

    # NOTE we consider xxxx as this year and next year
    And the following holidays exist
      | inventory pool | name      | start date | end date   |
      | A-Ausleihe     | Christmas | 24.12.xxxx | 26.12.xxxx |
      | IT-Ausleihe    | Christmas | 24.12.xxxx | 26.12.xxxx |
      | AV-Technik     | Christmas | 24.12.xxxx | 26.12.xxxx |

    Then there are 6 holidays in total

    And the following building exists:
      | name                   | code |
      | Ausstellungsstrasse 60 | AU60 |

    Then there are 1 buildings in total

    And the following location exists:
      | room  | shelf   | building code |
      | SQ2   | Desk    | AU60          |
      | UG 13 | Ausgabe | AU60          |

    Then there are 2 locations in total

    Then there are 0 models in total

    And the following models exist:
      | product              | version | manufacturer | description                                  | hand over note                                    | maintenance period |
      | MacBookPro           |         | Apple        | Laptop für Studis und Angestellte.           | Mit Verpackung aushändigen.                       | 0                  |
      | Sharp Beamer         | 123     | Sharp        | Beamer, geeignet für alle Verwendungszwecke. | Beamer braucht ein VGA Kabel!                     | 0                  |
      | Sharp Beamer 2D      |         | Sharp        | Beamer, geeignet für alle Verwendungszwecke. |                                                   | 0                  |
      | Mini Beamer          |         | Panasonic    | Beamer, geeignet für alle Verwendungszwecke. |                                                   | 0                  |
      | Sharp Beamer         | 456     | Panasonic    | Beamer, geeignet für alle Verwendungszwecke. | Beamer braucht ein VGA Kabel!                     | 0                  |
      | Ultra Compact Beamer |         | Sony         | Besonders kleiner Beamer.                    | Beamer braucht ein VGA Kabel!                     | 0                  |
      | Micro Beamer         |         | Micro        | Besonders mikro kleiner Beamer.              | Beamer braucht ein VGA Kabel!                     | 0                  |
      | Kamera Nikon         | X12     | Nikon        | Super Kamera.                                | Kamera braucht Akkus!                             | 0                  |
      | Kamera Stativ        | 123     | Feli         | Stabiles Kamera Stativ                       | Stativ muss mit Stativtasche ausgehändigt werden. | 0                  |
      | Hifi Standard        |         | Sony         |                                              |                                                   |                    |
      | Bose AE2W            |         | Bose         | #{Faker::Lorem.paragraph}                    |                                                   |                    |
      | Bose XG4             |         | Bose         | #{Faker::Lorem.paragraph}                    |                                                   |                    |
      | Kamera Canon D5      |         | Canon        | Ganz teure Kamera                            | Kamera braucht Akkus!                             | 0                  |
      | Windows Laptop       |         | Microsoft    | Ein Laptop der Marke Microsoft               | Laptop mit Tasche ausgeben                        | 0                  |
      | Walkera v120         | 1G      | Walkera      | 3D Helikopter                                |                                                   | 0                  |
      | Walkera v120         | 2G      | Walkera      | 3D Helikopter                                |                                                   | 0                  |
      | Walkera v120         | 3G      | Walkera      | 3D Helikopter                                |                                                   | 0                  |
      | iMac                 |         | Apple        | Apples alter iMac                            |                                                   | 0                  |
      | MacBook Air          |         | Apple        |                                              |                                                   | 0                  |
      | Thinkpad             | X230    | Lenovo       |                                              |                                                   | 0                  |
      | Thinkpad             | X301    | Lenovo       |                                              |                                                   | 0                  |
      | Thinkpad             | Carbon  | Lenovo       |                                              |                                                   | 0                  |
      | Inspiron             | 7000    | Dell         |                                              |                                                   | 0                  |

    Then there are 23 models in total
    Then there are 0 items in total

    And the following categories exist:
      | name          | parent name |
      | Beamer        |             |
      | Kameras       |             |
      | Stative       |             |
      | Hifi-Anlagen  |             |
      | Notebooks     |             |
      | RC Helikopter |             |
      | Computer      |             |
      | Kurzdistanz   | Kameras     |
      | Portabel      | Notebooks   |
      | Portabel      | Beamer      |
      | Standard      | Kameras     |
      | Standard      | Notebooks   |
      | Micro         | Portabel    |

    Then there are 11 categories in total

    And there exists 20 models of category "Beamer" each with 1 item with following properties:
      | model name | model manufacturer | model hand over note          | location room | location shelf | building code | inventory pool |
      | Beamer     | Sony               | Beamer braucht ein VGA Kabel! | SQ2           | Desk           | AU60          | A-Ausleihe     |

    Then there are 43 models in total
    Then there are 20 items in total

    And there exists 30 models of category "Kameras" each with 1 item with following properties:
      | model name | model manufacturer | model hand over note | location room | location shelf | building code | inventory pool |
      | Camera     | Nikon              |                      | SQ2           | Desk           | AU60          | A-Ausleihe     |

    Then there are 73 models in total
    Then there are 50 items in total

    And the category "Kameras" has 1 image

    And the following categories have the following models:
      | category name | model name           |
      | Notebooks     | MacBookPro           |
      | Beamer        | Sharp Beamer 123     |
      | Portabel      | Sharp Beamer 123     |
      | Beamer        | Sharp Beamer 2D      |
      | Beamer        | Mini Beamer          |
      | Beamer        | Ultra Compact Beamer |
      | Portabel      | Ultra Compact Beamer |
      | Micro         | Micro Beamer         |
      | Kameras       | Kamera Nikon         |
      | Stative       | Kamera Stativ        |
      | Hifi-Anlagen  | Hifi Standard        |
      | Kameras       | Kamera Canon D5      |
      | Notebooks     | Windows Laptop       |
      | RC Helikopter | Walkera v120 1G      |
      | RC Helikopter | Walkera v120 2G      |
      | RC Helikopter | Walkera v120 3G      |
      | Computer      | iMac                 |

    And the model "Walkera v120 1G" has the following properties:
      | key              | value |
      | Rotordurchmesser | 120   |
      | Akkus            | 2     |
      | Farbe            | Rot   |

    And the model "Walkera v120 2G" has the following properties:
      | key              | value    |
      | Rotordurchmesser | 120      |
      | Akkus            | 2        |
      | Farbe            | Rot      |
      | max. Speed       | 80 kmh   |
      | Gyro             | Ja       |
      | Achsen           | 3-Achsen |

    And the model "Walkera v120 3G" has the following properties:
      | key              | value |
      | Rotordurchmesser | 120   |
      | Akkus            | 2     |
      | Farbe            | Rot   |

    And the model "Walkera v120 1G" has the following compatibles:
      | model name     |
      | Windows Laptop |

    And the model "Walkera v120 2G" has the following compatibles:
      | model name     |
      | Windows Laptop |

    And the model "Walkera v120 3G" has the following compatibles:
      | model name     |
      | Windows Laptop |

    And the model "Walkera v120 2G" has 1 attachment
    And the model "Walkera v120 3G" has 1 attachment

    And the model "Walkera v120 2G" has 2 images
    And the model "Walkera v120 3G" has 1 image

    And each of the models has from 1 to 5 accessories possibly activated for the inventory pool "A-Ausleihe"

    And the following items exist:
      | inventory code | serial number | product name         | name       | retired       | retired reason           | is borrowable | is broken | is incomplete | inventory pool name | owner name  | location room | location shelf | building code |
      | book1          | book1         | MacBookPro           |            |               |                          |               |           |               |                     | IT-Ausleihe | SQ2           | Desk           | AU60          |
      | book2          | book2         | MacBookPro           |            |               |                          |               |           |               |                     | IT-Ausleihe | SQ2           | Desk           | AU60          |
      | beam123        | xyz456        | Sharp Beamer 123     |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | beam345        | xyz890        | Sharp Beamer 123     |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | beam678        | xyz678        | Sharp Beamer 2D      |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | beam749        | xyz749        | Sharp Beamer 123     |            |               |                          |               |           |               | IT-Ausleihe         | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | beamTest123    | xyz74912      | Sharp Beamer 456     |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | ucbeam1        | minbeam1      | Ultra Compact Beamer | ucbeam1    |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | microbeam1     | microbeam1    | Micro Beamer         | microbeam1 |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | cam123         | abc234        | Kamera Nikon         |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | cam345         | ab567         | Kamera Nikon         |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | cam567         | ab789         | Kamera Nikon         |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | cam53267       | ab782129      | Kamera Nikon         |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | cam532asd67    | ab78as2129    | Kamera Nikon         |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | tri789         | fgh567        | Kamera Stativ        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | tri123         | fgh987        | Kamera Stativ        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | tri923         | asd213        | Kamera Stativ        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | tri212         | tri212        | Kamera Stativ        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | hifi123        | hifi123       | Hifi Standard        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | bose123        | bose123       | Bose XG4             |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | cand5          | cand5         | Kamera Nikon         |            |               |                          | false         |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | beam21231      | beamas12312   | Sharp Beamer 123     |            |               |                          | false         |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | hifi345        | hifi345       | Hifi Standard        |            |               |                          | false         |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | wlaptop1       | wlaptop1      | Windows Laptop       |            |               |                          |               | true      |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | v120d02        | v120d02       | Walkera v120 1G      |            |               |                          |               |           | true          |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | v120d11        | v120d11       | Walkera v120 1G      |            | #{Date.today} | #{Faker::Lorem.sentence} | false         | true      | true          |                     | A-Ausleihe  |               |                |               |
      | v120d022g      | v120d022g     | Walkera v120 2G      |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | v120d022g2     | v120d022g2    | Walkera v120 2G      |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | iMac1          | iMac1         | iMac                 |            | #{Date.today} | This item is gone.       |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | iMac2          | iMac2         | iMac                 |            | #{Date.today} | This item is gone.       |               |           |               | A-Ausleihe          | AV-Technik  | SQ2           | Desk           | AU60          |
      | lpv3yc         | lpv3yc        | Bose AE2W            |            | #{Date.today} | This item is gone.       |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | 6cxjcs         | 6cxjcs        | Bose AE2W            |            | #{Date.today} | This item is gone.       |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | beam897        | beam897       | Sharp Beamer 123     |            |               |                          |               |           |               |                     | IT-Ausleihe | SQ2           | Desk           | AU60          |
      | minibeam12     | minibeam12    | Mini Beamer          |            |               |                          |               |           |               |                     | IT-Ausleihe | SQ2           | Desk           | AU60          |
      | minibeam34     | minibeam34    | Mini Beamer          |            |               |                          |               |           |               |                     | AV-Technik  | SQ2           | Desk           | AU60          |
      | minibeam56     | minibeam56    | Mini Beamer          |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | minibeam78     | minibeam78    | Mini Beamer          |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | air123         | air123        | MacBook Air          |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | tp230          | tp230         | Thinkpad X230        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | tp301          | tp301         | Thinkpad X301        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | carbon1        | carbon1       | Thinkpad Carbon      |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | carbon2        | carbon2       | Thinkpad Carbon      |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      | inspiron1      | inspiron1     | Inspiron 7000        |            |               |                          |               |           |               |                     | A-Ausleihe  | SQ2           | Desk           | AU60          |
      |                |               |                      |            |               |                          |               |           |               | IT-Ausleihe         | A-Ausleihe  | SQ2           | Desk           | AU60          |

    Then there are 94 items in total
    Then there are 5 retired items in total
    Then there are 2 broken items in total
    Then there are 2 incomplete items in total

    And the following software exists:
      | product       | technical detail                                 |
      | Adobe Acrobat | test http://test.ch\r\nwww.foo.ch\r\njust a text |
      | MS Word       | test http://test.ch\r\nwww.foo.ch\r\njust a text |

    And the software "Adobe Acrobat" has from 1 to 3 attachments
    And the software "MS Word" has from 1 to 3 attachments

    And there exist more than 2 and less then 6 arbitrary licenses for the inventory pool "A-Ausleihe"

    And the following licenses exist:
      | inventory code | software name | owner name  | inventory pool name | is borrowable           | retired       | retired reason           | invoice date  | license expiration | maintenance contract | maintenance expiration | operating system                                           | license type                                             | total quantity |
      |                |               | A-Ausleihe  | IT-Ausleihe         | #{[true, false].sample} |               |                          |               |                    |                      |                        |                                                            |                                                          |                |
      |                |               | A-Ausleihe  |                     | #{[true, false].sample} | #{Date.today} | #{Faker::Lorem.sentence} |               |                    |                      |                        |                                                            |                                                          |                |
      |                |               | IT-Ausleihe | A-Ausleihe          | #{[true, false].sample} | #{Date.today} | #{Faker::Lorem.sentence} |               |                    |                      |                        |                                                            |                                                          |                |
      |                |               | IT-Ausleihe |                     | true                    |               |                          |               |                    |                      |                        |                                                            |                                                          |                |
      |                |               | A-Ausleihe  |                     | #{[true, false].sample} |               |                          | #{Date.today} | #{Date.today}      | true                 | #{Date.today}          |                                                            |                                                          |                |
      | acrobat123     | Adobe Acrobat | A-Ausleihe  |                     | #{[true, false].sample} |               |                          |               |                    |                      |                        |                                                            |                                                          |                |
      | msword123      |               | A-Ausleihe  |                     | #{[true, false].sample} |               |                          |               |                    |                      |                        | #{%w(windows linux mac_os_x).sample(rand(1..2)).join(',')} | #{%w(concurrent site_license multiple_workplace).sample} | #{rand(300)}   |
      | lic111         |               | A-Ausleihe  | IT-Ausleihe         | #{[true, false].sample} |               |                          |               |                    |                      |                        | #{%w(windows linux mac_os_x).sample(rand(1..2)).join(',')} | #{%w(concurrent site_license multiple_workplace).sample} | #{rand(300)}   |
      |                |               | A-Ausleihe  | A-Ausleihe          | #{[true, false].sample} |               |                          |               |                    |                      |                        | #{%w(windows linux mac_os_x).sample(rand(1..2)).join(',')} | #{%w(concurrent site_license multiple_workplace).sample} | #{rand(300)}   |

    And the license with inventory code "acrobat123" has to following quantity allocations:
      | room                 | quantity       |
      | #{Faker::Lorem.word} | #{rand(1..50)} |
      | #{Faker::Lorem.word} | #{rand(1..50)} |

    And the license with inventory code "msword123" has to following quantity allocations:
      | room                 | quantity       |
      | #{Faker::Lorem.word} | #{rand(1..50)} |
      | #{Faker::Lorem.word} | #{rand(1..50)} |

    And the following package model with 3 items exists:
      | product name | inventory pool name |
      | Kamera Set   | A-Ausleihe          |

    And the following package model with 1 item exists:
      | product name | inventory pool name |
      | Kamera Set   | IT-Ausleihe         |

    And the following package model with 3 items exists:
      | product name | inventory pool name |
      | Kamera Set2  | A-Ausleihe          |

    Then there are 2 package models in total

    And the following options exist:
      | inventory code | product name | inventory pool name |
      | akku-aa        | Akku AA      | A-Ausleihe          |
      | akku-aaa       | Akku AAA     | A-Ausleihe          |
      | usb            | USB Kabel    | A-Ausleihe          |
      | sandsack123    | Sandsack     | A-Ausleihe          |

    Then there are 4 options in total

    And template "Kamera & Stativ" with the following quantities exists:
      | model name    | quantity |
      | Kamera Nikon  | 1        |
      | Kamera Stativ | 1        |
    And the template "Kamera & Stativ" is used in the inventory pool "A-Ausleihe"

    And template "Beamer & Hifi" with the following quantities exists:
      | model name       | quantity |
      | Sharp Beamer 123 | 1        |
      | Hifi Standard    | 1        |
    And the template "Beamer & Hifi" is used in the inventory pool "A-Ausleihe"

    And template "Unaccomplishable template" with the following quantities exists:
      | model name    | quantity |
      | Kamera Nikon  | 999      |
      | Kamera Stativ | 999      |
    And the template "Unaccomplishable template" is used in the inventory pool "A-Ausleihe"

    Then there are 3 templates in total

    And the following groups exist:
      | name        | inventory pool | verification required |
      | Cast        | A-Ausleihe     | false                 |
      | IAD         | A-Ausleihe     | false                 |
      | Wu          | A-Ausleihe     | false                 |
      | Group Hifi  | A-Ausleihe     | false                 |
      | Group A     | A-Ausleihe     | false                 |
      | Group B     | A-Ausleihe     | false                 |
      | FFI         | A-Ausleihe     | true                  |
      | VTO         | A-Ausleihe     | true                  |
      | 1. Semester | IT-Ausleihe    | true                  |
      | Group C     | A-Ausleihe     | false                 |

    Then there are 10 groups in total

    And the group "Cast" hast following users:
      | user email     |
      | normin@zhdk.ch |
      | lisa@zhdk.ch   |

    And the group "FFI" hast following users:
      | user email        |
      | customer1@zhdk.ch |
      | customer2@zhdk.ch |
      | customer3@zhdk.ch |
      | customer4@zhdk.ch |
      | customer5@zhdk.ch |

    And the group "VTO" hast following users:
      | user email        |
      | customer1@zhdk.ch |
      | customer3@zhdk.ch |

    And the group "1. Semester" hast following users:
      | user email        |
      | customer4@zhdk.ch |

    And the group "Group C" hast following users:
      | user email        |
      | customer6@zhdk.ch |

    And the following partitions exist:
      | inventory pool name | group name | model name       | quantity |
      | A-Ausleihe          | Group Hifi | Hifi Standard    | 1        |
      | A-Ausleihe          | Cast       | Kamera Nikon X12 | 1        |
      | A-Ausleihe          | IAD        | Kamera Nikon X12 | 1        |
      | A-Ausleihe          | Cast       | Walkera v120 1G  | 1        |
      | A-Ausleihe          | Group A    | Walkera v120 2G  | 1        |
      | A-Ausleihe          | Group B    | Walkera v120 3G  | 5        |
      | A-Ausleihe          | FFI        | MacBook Air      | 1        |
      | A-Ausleihe          | FFI        | Thinkpad X301    | 1        |
      | A-Ausleihe          | VTO        | Thinkpad X230    | 1        |
      | A-Ausleihe          | Group C    | Thinkpad Carbon  | 1        |

    Then there are 10 partitions in total

    And 3 unsubmitted contract line exists
    And 3 unsubmitted contract line for user "normin@zhdk.ch" exists

    And all unsubmitted contract lines are available
    
    And 3 to 5 submitted item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Benötige ich für die Aufnahmen meiner Abschlussarbeit. |
      | start date | #{Date.today + 7.days}                                 |
      | end date   | #{Date.today + 10.days}                                |
      | model name | Kamera Nikon X12                                       |
    And 3 to 5 submitted item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Benötige ich für die Aufnahmen meiner Abschlussarbeit. |
      | start date | #{Date.today + 7.days}                                 |
      | end date   | #{Date.today + 10.days}                                |
      | model name | Kamera Stativ 123                                      |

    And 1 to 1 submitted item lines with following properties exists:
      | user email          | customer6@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | assigned   | false                 |
      | model name | Thinkpad Carbon       |
      | start date | #{Date.today}         |
      | end date   | #{Date.today + 1.day} |

    And 4 submitted contract lines for user "normin@zhdk.ch" exist

    And today is "#{Time.now - rand(1..7).days}"
    And 3 to 5 submitted item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |
    And 1 to 1 submitted item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | MacBook Air                       |
    And today is back to initial random date

    And 3 to 5 submitted item lines with following properties exists:
      | user email          | customer2@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |
    And 1 to 1 submitted item lines with following properties exists:
      | user email          | customer2@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | Thinkpad X301                     |

    And 3 to 5 submitted item lines with following properties exists:
      | user email          | customer3@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |

    And 3 to 5 submitted item lines with following properties exists:
      | user email          | customer4@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |

    And 3 to 5 submitted item lines with following properties exists:
      | user email          | customer5@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |

    And today is "#{Time.now - rand(1..7).days}"
    And 3 to 5 submitted item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |
    And 2 to 2 submitted item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | Thinkpad X230                     |
    And today is back to initial random date

    And today is "#{Time.now - rand(1..7).days}"
    And 3 to 5 submitted item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |
    And today is back to initial random date

    And 1 to 1 submitted item lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | purpose    | Für meinen aktuellen Kurs. |
      | start date | #{Date.today + 7.days}     |
      | end date   | #{Date.today + 10.days}    |
      | model name | Kamera Nikon X12           |
    And 1 to 1 submitted item lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | purpose    | Für meinen aktuellen Kurs. |
      | start date | #{Date.today + 7.days}     |
      | end date   | #{Date.today + 10.days}    |
      | model name | Kamera Stativ 123          |
    And 1 to 1 submitted item lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | purpose    | Für meinen aktuellen Kurs. |
      | start date | #{Date.today + 8.days}     |
      | end date   | #{Date.today + 11.days}    |
      | model name | Kamera Stativ 123          |

    And 1 to 1 submitted item lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | purpose    | Für meinen aktuellen Kurs. |
      | start date | #{Date.today}              |
      | end date   | #{Date.today + 1.days}     |
      | model name | Ultra Compact Beamer       |

    And 1 approved contract line exists

    And 30 to 40 approved item lines with following properties exists:
      | user email          | customer9@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | assigned | true |
    And 1 to 2 approved item lines with following properties exists:
      | user email          | customer9@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | assigned | false |

    And today is "#{Time.now - rand(1..7).days}"
    And 3 to 5 approved item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |
    And 1 to 1 approved item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | MacBook Air                       |
    And today is back to initial random date

    And today is "#{Time.now - rand(3..5).months}"
    And 1 to 1 approved item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | assigned   | true                              |
      | item       | air123                            |
      | model name | MacBook Air                       |
      | purpose    | Ersatzstativ für die Ausstellung. |
    And this contract is signed by "pius@zhdk.ch"
    And this contract is closed on "#{Date.today}" by "pius@zhdk.ch"
    And today is back to initial random date

    And 1 to 1 approved item lines with following properties exists:
      | user email          | customer8@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | assigned | true |
    And 1 to 1 more approved option lines with following properties exists:
      | user email          | customer8@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | quantity | 2 |
    And this contract is signed by "pius@zhdk.ch"

    And 1 to 1 approved option lines with following properties exists:
      | user email          | peter@silie.com |
      | inventory pool name | A-Ausleihe      |
      | inventory code | sandsack123       |
      | quantity       | 2                 |
      | start date     | #{Date.yesterday} |
      | end date       | #{Date.today}     |
    And 1 to 1 more approved option lines with following properties exists:
      | user email          | peter@silie.com |
      | inventory pool name | A-Ausleihe      |
      | inventory code | sandsack123             |
      | quantity       | 1                       |
      | start date     | #{Date.yesterday}       |
      | end date       | #{Date.today + 1.month} |
    And this contract is signed by "pius@zhdk.ch"

    And 1 to 1 approved license lines with following properties exists:
      | inventory pool name | A-Ausleihe |
      | assigned | true |
    And this contract is signed by "pius@zhdk.ch"

    And today is "#{Time.now - 5.days}"
    And 1 to 1 approved item lines with following properties exists:
      | inventory pool name | IT-Ausleihe |
      | start date | #{Date.today}          |
      | end date   | #{Date.today + 4.days} |
    And 1 to 1 approved option lines with following properties exists:
      | inventory pool name | IT-Ausleihe |
      | start date | #{Date.today}          |
      | end date   | #{Date.today + 4.days} |
    And today is back to initial random date

    And 1 to 1 approved item lines with following properties exists:
      | inventory pool name | A-Ausleihe |
      | assigned       | true       |
      | inventory code | minibeam56 |
    And this contract is signed by "pius@zhdk.ch"
    And this contract is closed on "#{Date.today}" by "pius@zhdk.ch"
    And the item with inventory code "minibeam56" has now the following properties:
      | retired        | #{Date.today}            |
      | retired reason | #{Faker::Lorem.sentence} |

    And 1 to 1 approved item lines with following properties exists:
      | inventory pool name | A-Ausleihe |
      | assigned       | true       |
      | inventory code | minibeam78 |
    And this contract is signed by "pius@zhdk.ch"
    And this contract is closed on "#{Date.today}" by "pius@zhdk.ch"
    And the item with inventory code "minibeam78" has now the following properties:
      | inventory pool name | IT-Ausleihe |
      | owner name          | IT-Ausleihe |

    And 1 to 1 approved item lines with following properties exists:
      | user email          | customer7@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | assigned | true |
    And this contract is signed by "pius@zhdk.ch"
    And this contract is closed on "#{Date.today}" by "pius@zhdk.ch"

    And 1 to 1 approved item lines with following properties exists:
      | user email          | customer7@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | model package name | Kamera Set2 |
      | item               | in_stock    |
      | assigned           | true        |
    And this contract is signed by "pius@zhdk.ch"
    And this contract is closed on "#{Date.today}" by "pius@zhdk.ch"

    And the following access right is revoked:
      | user email          | customer7@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
    
    And 1 to 1 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | Kamera Stativ 123                 |

    And 1 to 1 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Für das zweite Austellungswochenende. |
      | model name | Kamera Stativ 123                     |
    And 1 to 1 more approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Für das zweite Austellungswochenende. |
      | model name | Sharp Beamer 123                      |

    And 1 to 1 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Für das dritte Austellungswochenende. |
      | start date | #{Date.today + 7.days}                |
      | end date   | #{Date.today + 8.days}                |
      | model name | Kamera Stativ 123                     |

    And 3 to 3 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Für die Abschlussarbeit. |
      | model name | Sharp Beamer 123         |

    And 3 to 3 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | Kamera Nikon X12                  |
    And 3 to 3 more approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | Kamera Stativ 123                 |
    And 1 to 1 more approved option lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose        | Ersatzstativ für die Ausstellung. |
      | inventory code | akku-aa                           |
      | quantity       | 5                                 |

    And 1 to 1 approved license lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose | Bestellung mit Software |

    And 1 to 1 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | purpose       | Bestellung mit Gegenstand ohne Ort |
      | item          | owned                              |
      | item location | nil                                |

    And 1 to 1 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | assigned   | true                                       |
      | purpose    | Um meine Abschlussarbeit zu fotografieren. |
      | start date | #{Date.yesterday}                          |
      | end date   | #{Date.today}                              |
      | model name | Kamera Nikon X12                           |
      | item       | in_stock                                   |
    And this contract is signed by "pius@zhdk.ch"

    And today is "#{Time.now - 5.days}"
    And 1 to 1 approved item lines with following properties exists:
      | user email          | lisa@zhdk.ch |
      | inventory pool name | A-Ausleihe   |
      | assigned   | true                   |
      | purpose    | Als Ersatz.            |
      | start date | #{Date.today}          |
      | end date   | #{Date.today + 4.days} |
      | model name | Inspiron 7000          |
      | item       | in_stock               |
    And 1 to 1 more approved option lines with following properties exists:
      | user email          | lisa@zhdk.ch |
      | inventory pool name | A-Ausleihe   |
      | quantity | 1 |
    And this contract is signed by "pius@zhdk.ch"
    And today is back to initial random date

    And 1 to 1 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | assigned   | true              |
      | start date | #{Date.yesterday} |
      | end date   | #{Date.today}     |
      | item       | owned             |
    And this contract is signed by "pius@zhdk.ch"

    And 2 to 2 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | IT-Ausleihe    |
      | assigned   | true                                       |
      | purpose    | Um meine Abschlussarbeit zu fotografieren. |
      | start date | #{Date.yesterday}                          |
      | end date   | #{Date.today}                              |
    And this contract is signed by "pius@zhdk.ch"
    And 1 to 1 of these item lines is returned:
      | returned date    | #{Date.today}                              |
      | returned to user | pius@zhdk.ch                               |

    And 1 to 1 approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | IT-Ausleihe    |
      | assigned   | true                                       |
      | purpose    | Um meine Abschlussarbeit zu fotografieren. |
      | start date | #{Date.yesterday}                          |
      | end date   | #{Date.today}                              |
      | model name | Sharp Beamer 123                           |
      | item       | lic111                                     |
    And 1 to 1 more approved item lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | IT-Ausleihe    |
      | assigned | true    |
      | item     | beam749 |
    And this contract is signed by "pius@zhdk.ch"

    And 1 to 1 approved license lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | IT-Ausleihe    |
      | assigned   | true              |
      | start date | #{Date.yesterday} |
      | end date   | #{Date.today}     |
      | item       | owned             |
    And this contract is signed by "pius@zhdk.ch"

    And 1 to 1 approved license lines with following properties exists:
      | user email          | normin@zhdk.ch |
      | inventory pool name | A-Ausleihe     |
      | assigned           | true              |
      | purpose            | Paketausgabe      |
      | start date         | #{Date.yesterday} |
      | end date           | #{Date.today}     |
      | model package name | Kamera Set        |
      | item               | in_stock          |
    And this contract is signed by "pius@zhdk.ch"

    And 1 to 1 approved item lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | start date | #{Date.yesterday - 1.day}         |
      | end date   | #{Date.today + 1.day}             |
      | model name | Sharp Beamer 123                  |
    And 1 to 1 more approved item lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | start date | #{Date.yesterday - 1.day}         |
      | end date   | #{Date.today + 1.day}             |

    And 1 to 1 submitted item lines with following properties exists:
      | user email          | lisa@zhdk.ch |
      | inventory pool name | A-Ausleihe   |
      | assigned         | false                                             |
      | purpose          | Ganz dringend benötigt für meine Abschlussarbeit. |
      | model name       | Thinkpad Carbon                                   |
      | soft overbooking | true                                              |

    And 1 to 1 approved item lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | assigned   | true                                       |
      | purpose    | Um meine Abschlussarbeit zu fotografieren. |
      | start date | #{Date.yesterday}                          |
      | end date   | #{Date.today}                              |
      | model name | Sharp Beamer 123                           |
      | item       | in_stock                                   |
    And 1 to 1 more approved option lines with following properties exists:
      | user email          | petra@zhdk.ch |
      | inventory pool name | A-Ausleihe    |
      | purpose        | Um meine Abschlussarbeit zu fotografieren. |
      | inventory code | akku-aa                                    |
      | start date     | #{Date.yesterday}                          |
      | end date       | #{Date.today}                              |
    And this contract is signed by "pius@zhdk.ch"

    And 1 to 1 submitted item lines with following properties exists:
      | user email          | lisa@zhdk.ch |
      | inventory pool name | A-Ausleihe   |
      | assigned   | false                           |
      | purpose    | Fotoshooting (Kurs Fotografie). |
      | start date | #{Date.today + 37.days}         |
      | end date   | #{Date.today + 45.days}         |
      | model name | Kamera Nikon X12                |

    And 1 to 1 submitted item lines with following properties exists:
      | user email          | lisa@zhdk.ch |
      | inventory pool name | A-Ausleihe   |
      | assigned         | false                                 |
      | purpose          | Brauche ich zwingend für meinen Kurs. |
      | start date       | #{Date.today + 52.days}               |
      | end date         | #{Date.today + 55.days}               |
      | model name       | Kamera Nikon X12                      |
      | real overbooking | true                                  |

    And 3 to 5 submitted item lines with following properties exists:
      | delegation name      | Delegation 1 |
      | delegated user email | mina@zhdk.ch |
      | inventory pool name  | A-Ausleihe   |
      | assigned | false |

    And 3 to 5 approved item lines with following properties exists:
      | delegation name      | Delegation 1  |
      | delegated user email | julie@zhdk.ch |
      | inventory pool name  | A-Ausleihe    |
      | assigned   | false         |
      | start date | #{Date.today} |

    And 3 to 5 approved item lines with following properties exists:
      | delegation name      | Delegation 5       |
      | delegated user email | delegated1@zhdk.ch |
      | inventory pool name  | A-Ausleihe         |
      | assigned   | true          |
      | start date | #{Date.today} |

    And 3 to 5 approved item lines with following properties exists:
      | delegation name      | Delegation 1 |
      | delegated user email | mina@zhdk.ch |
      | inventory pool name  | A-Ausleihe   |
      | assigned   | true          |
      | start date | #{Date.today} |
    And this contract is signed by "pius@zhdk.ch"

    And today is "#{Time.now - 5.days}"
    And 3 to 5 approved item lines with following properties exists:
      | delegation name      | Delegation 1 |
      | delegated user email | mina@zhdk.ch |
      | inventory pool name  | A-Ausleihe   |
      | assigned   | true          |
      | start date | #{Date.today} |
    And this contract is signed by "pius@zhdk.ch"
    And today is back to initial random date

    And today is "#{Time.now - rand(1..7).days}"
    And 3 to 5 rejected item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose | Ersatzstativ für die Ausstellung. |
    And 1 to 1 rejected item lines with following properties exists:
      | user email          | customer1@zhdk.ch |
      | inventory pool name | A-Ausleihe        |
      | purpose    | Ersatzstativ für die Ausstellung. |
      | model name | MacBook Air                       |
    And today is back to initial random date

    Then there are 18 contracts in total

    And all unsubmitted contract lines are available

    Then the current time dump is generated
