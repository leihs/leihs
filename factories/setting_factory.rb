# coding: UTF-8

FactoryGirl.define do

  factory :setting do
    smtp_address { "smtp.zhdk.ch" }
    smtp_port { 25 }
    smtp_domain { "beta.ausleihe.zhdk.ch" }
    mail_delivery_method { 'test' }
    local_currency_string { "CHF" }
    contract_terms { "Die Benutzerin/der Benutzer ist bei unsachgemässer Handhabung oder Verlust schadenersatzpflichtig. Sie/Er verpflichtet sich, das Material sorgfältig zu behandeln und gereinigt zu retournieren. Bei mangelbehafteter oder verspäteter Rückgabe kann eine Ausleihsperre (bis zu 6 Monaten) verhängt werden. Das geliehene Material bleibt jederzeit uneingeschränktes Eigentum der Zürcher Hochschule der Künste und darf ausschliesslich für schulische Zwecke eingesetzt werden. Mit ihrer/seiner Unterschrift akzeptiert die Benutzerin/der Benutzer diese Bedingungen sowie die 'Richtlinie zur Ausleihe von Sachen' der ZHdK und etwaige abteilungsspezifische Ausleih-Richtlinien." }
    contract_lending_party_string { "Your\nAddress\nHere" }
    email_signature { "Das PZ-leihs Team" }
    default_email { 'sender@example.com' }
    deliver_order_notifications { false }
    user_image_url { "http://www.zhdk.ch/?person/foto&width=100&compressionlevel=0&id={:id}" }
    logo_url { "/assets/image-logo-zhdk.png" }
    disable_manage_section { false }
    disable_manage_section_message { '' }
    disable_borrow_section { false }
    disable_borrow_section_message { '' }
  end

end
