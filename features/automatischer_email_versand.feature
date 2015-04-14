
Feature: Automatischer E-Mail versand
  Background:
    Given Das System ist für den Mailversand im Testmodus konfiguriert
    And I am Normin

  @personas
  Scenario: Automatische Rückgabeerinnerung
    Given ich habe eine nicht verspätete Rückgabe
    Then wird mir einen Tag vor der Rückgabe eine Erinnerungs E-Mail zugeschickt

  @personas
  Scenario: Automatische Erinerung bei verpasster Rückgabe
    Given ich habe eine verspätete Rückgabe
    Then erhalte ich einen Tag nach Rückgabedatum eine Erinnerungs E-Mail zugeschickt
    And für jeden weiteren Tag erhalte ich erneut eine Erinnerungs E-Mail zugeschickt
    
