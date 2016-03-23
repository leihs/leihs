# desc "Explaining what the task does"
# task :procurement do
#   # Task goes here
# end

namespace :procurement do
  desc 'Procurement data seed'
  task seed: :environment do

    # Procurement::Access.admins.map &:user_id
    [1973, 5824, 601, 9103, 10558, 7329, 7815].each do |user_id|
      Procurement::Access.admins.create! user_id: user_id
    end

    # h = {}; Procurement::Access.requesters.each {|x| h[x.user_id] = [x.organization.parent.name, x.organization.name]}; h
    { 12 => ['Services', 'PZ'], 3881 => ['PZ', 'Technik Produktion'],
      326 => ['DDK', 'IPF'], 10 => ['Services', 'ITZ'], 1363 => ['DDK', 'BA Film'],
      735 => ['DKV', 'Museum für Gestaltung'], 3911 => ['DKM', 'IFCAR'],
      8479 => ['DKV', 'Institut für Theorie'],
      4491 => ['DDK', 'Departementsleitung'], 114 => ['Services', 'FM'],
      3848 => ['DMU', 'Betriebsleiter'], 317 => ['Services', 'ITZ'],
      9103 => ['Services', 'ITZ'], 2415 => ['DMU', 'Departementsleitung'],
      350 => ['Services', 'PZ'], 422 => ['DKM', 'BA Arts in Medien und Kunst'],
      5824 => ['Services', 'ITZ'], 1260 => ['DKV', 'BA Art Education'],
      9069 => ['DMU', 'BA of Arts in Musik'], 8909 => ['DDK', 'TaZ'],
      5844 => ['DKV', 'ICS'],
      1438 => ['DKM', 'Master Fine Arts'] }.each_pair do |user_id, organization_names|
      parent = Procurement::Organization.find_or_create_by!(name: organization_names.first)
      organization = parent.children.find_or_create_by!(name: organization_names.last)
      Procurement::Access.requesters.find_or_create_by! user_id: user_id,
                                                        organization: organization
    end

    # Procurement::Group.all.map {|x| attrs = x.attributes; attrs[:inspector_ids] = x.inspector_ids; attrs }
    [{ 'id' => 6, 'name' => 'AV', 'email' => 'service.avt@zhdk.ch', :inspector_ids => [350] },
     { 'id' => 10, 'name' => 'Facility Management', 'email' => 'service.fm@zhdk.ch.ch', :inspector_ids => [114] },
     { 'id' => 12, 'name' => 'IT', 'email' => 'service.itz@zhdk.ch', :inspector_ids => [10, 317, 5824] },
     { 'id' => 8, 'name' => 'Musikinstrumente', 'email' => 'martin.weyermann@zhdk.ch', :inspector_ids => [3848] },
     { 'id' => 4, 'name' => 'Produktionstechnik', 'email' => 'alex.stierli@zhdk.ch', :inspector_ids => [3881] },
     { 'id' => 2, 'name' => 'Werkstatt-Technik', 'email' => 'adrian.brazerol@zhdk.ch', :inspector_ids => [12] }
    ].each do |h|
      Procurement::Group.create! h
    end

    # Procurement::BudgetPeriod.all.map {|x| {id: x.id, name: x.name, inspection_start_date: x.inspection_start_date.to_s, end_date: x.end_date.to_s}}
    [{ id: 2, name: '2017', inspection_start_date: '2016-01-14', end_date: '2016-01-16' },
     { id: 4, name: '2018', inspection_start_date: '2016-03-08', end_date: '2016-06-08' },
     { id: 6, name: '2019', inspection_start_date: '2016-01-20', end_date: '2018-12-31' }
    ].each do |h|
      Procurement::BudgetPeriod.create! h
    end

    # Procurement::BudgetLimit.all.map {|x| {group_id: x.group_id, budget_period_id: x.budget_period_id, amount: x.amount.to_i} }
    [{ group_id: 2, budget_period_id: 2, amount: 160000 },
     { group_id: 6, budget_period_id: 2, amount: 740000 },
     { group_id: 8, budget_period_id: 2, amount: 270000 },
     { group_id: 10, budget_period_id: 2, amount: 460000 },
     { group_id: 12, budget_period_id: 2, amount: 1_900_000 },
     { group_id: 12, budget_period_id: 4, amount: 0 },
     { group_id: 12, budget_period_id: 6, amount: 0 },
     { group_id: 6, budget_period_id: 6, amount: 1 },
     { group_id: 6, budget_period_id: 4, amount: 6 },
     { group_id: 10, budget_period_id: 6, amount: 0 },
     { group_id: 10, budget_period_id: 4, amount: 0 },
     { group_id: 4, budget_period_id: 2, amount: 480000 }].each do |h|
      Procurement::BudgetLimit.create! h
    end

    # Procurement::Request.all.map {|x| attrs = x.attributes; attrs.delete("id"); attrs.delete("created_at"); attrs }
    [{ 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Eizo 19 Zoll LCD Monitor M190020589 SCH', 'article_number' => nil, 'requested_quantity' => 4, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => false, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 8, 'user_id' => 5824, 'model_id' => 9443, 'supplier_id' => 20, 'location_id' => 8377, 'article_name' => 'Violabogen 3', 'article_number' => '111223A', 'requested_quantity' => 3, 'approved_quantity' => 3, 'order_quantity' => 3, 'price_cents' => 250000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => false, 'supplier_name' => 'Schumacher&Frey GMBH', 'receiver' => 'Silvan Gretener', 'location_name' => 'Toni-Areal (TONI)  14.D.01', 'motivation' => 'Meine Begründung', 'inspection_comment' => 'Zwei reichen völlig aus' },
     # {"budget_period_id" => 2, "group_id" => 10, "user_id" => 7815, "model_id" => nil, "supplier_id" => nil, "location_id" => nil, "article_name" => "Bürotisch", "article_number" => nil, "requested_quantity" => 1, "approved_quantity" => nil, "order_quantity" => nil, "price_cents" => 50000, "price_currency" => "CHF", "priority" => "high", "replacement" => false, "supplier_name" => "USM", "receiver" => "Hans Ulrich Gasser", "location_name" => nil, "motivation" => "neuer MA", "inspection_comment" => nil},
     # {"budget_period_id" => 4, "group_id" => 12, "user_id" => 7815, "model_id" => nil, "supplier_id" => nil, "location_id" => nil, "article_name" => "It Arbeitsplätze", "article_number" => nil, "requested_quantity" => 1, "approved_quantity" => 10, "order_quantity" => 10, "price_cents" => 120000, "price_currency" => "CHF", "priority" => "high", "replacement" => true, "supplier_name" => nil, "receiver" => nil, "location_name" => nil, "motivation" => "myasdfasdfsdf", "inspection_comment" => nil},
     # {"budget_period_id" => 4, "group_id" => 12, "user_id" => 7815, "model_id" => 9823, "supplier_id" => nil, "location_id" => nil, "article_name" => "Aktivlautsprecher audioengine Modell audioengine 5", "article_number" => nil, "requested_quantity" => 2, "approved_quantity" => nil, "order_quantity" => nil, "price_cents" => 0, "price_currency" => "CHF", "priority" => "normal", "replacement" => true, "supplier_name" => nil, "receiver" => nil, "location_name" => nil, "motivation" => "motivation", "inspection_comment" => nil},
     { 'budget_period_id' => 2, 'group_id' => 2, 'user_id' => 5824, 'model_id' => 14450, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Funkmikrofon Handsender Sennheiser SKM 2000', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'dfsdf', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 6, 'user_id' => 350, 'model_id' => 2639, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Beamer Acer H7531D Full-HD', 'article_number' => 'keine Ahnung', 'requested_quantity' => 1, 'approved_quantity' => 0, 'order_quantity' => 0, 'price_cents' => 123400, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => true, 'supplier_name' => 'MC Donald', 'receiver' => 'Martin Weyermann', 'location_name' => '5.B01-1', 'motivation' => 'Weil ich das will', 'inspection_comment' => 'nein' },
     { 'budget_period_id' => 2, 'group_id' => 8, 'user_id' => 3848, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Panflöte', 'article_number' => '8 Hölzig in Ges Dur', 'requested_quantity' => 2, 'approved_quantity' => 0, 'order_quantity' => 0, 'price_cents' => 1_180_000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => true, 'supplier_name' => 'Musikhaus Gurtner', 'receiver' => 'Claire Gwendoline', 'location_name' => 'DMU 6.E04', 'motivation' => 'Bestehendes Instrument abgespielt', 'inspection_comment' => 'braucht es noch nicht für lange lange lange zeit' },
     { 'budget_period_id' => 2, 'group_id' => 12, 'user_id' => 10, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Laptop: Lenovo Thinkpad X301 Intel C2 Duo 1.4GHz/64GB SSD/Wireless/BT mit 4096MB RAM', 'article_number' => nil, 'requested_quantity' => 8, 'approved_quantity' => 0, 'order_quantity' => 0, 'price_cents' => 230000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => true, 'supplier_name' => nil, 'receiver' => 'Hans Ueli Gasser', 'location_name' => 'Finanzen', 'motivation' => 'Endlich neue Computer', 'inspection_comment' => 'mit den neuen Akkus nicht mehr möglich' },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 10, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 8966, 'article_name' => 'Beamer', 'article_number' => nil, 'requested_quantity' => 37, 'approved_quantity' => 39, 'order_quantity' => 42, 'price_cents' => 950000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'der von Mike', 'receiver' => 'Barbara Berger', 'location_name' => 'Toni-Areal (TONI) 4.C12 itz-Büro ', 'motivation' => 'Ausstattung ITZ-Mitarbeitende für Home-Cinema', 'inspection_comment' => 'Darfs auch ein bisschen mehr sein?' },
     { 'budget_period_id' => 2, 'group_id' => 2, 'user_id' => 350, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Schraubzwingen', 'article_number' => '1234', 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 1300, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'NSA', 'receiver' => 'Alex Stierli', 'location_name' => 'Büro Gessnerallee', 'motivation' => 'Dieso', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 4, 'user_id' => 3848, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 6549, 'article_name' => 'Hammondorgel mit Lesley', 'article_number' => 'Hammond', 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 2_950_000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'Musighüsli Zürich', 'receiver' => 'Chris Wiesendanger', 'location_name' => 'Toni-Areal (TONI) ZT 4.C12 ', 'motivation' => 'Move the Power ', 'inspection_comment' => 'schon lange gewünscht immer verschoben' },
     { 'budget_period_id' => 2, 'group_id' => 10, 'user_id' => 10, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 9374, 'article_name' => 'Höhenverstellbares Pult', 'article_number' => nil, 'requested_quantity' => 15, 'approved_quantity' => 10, 'order_quantity' => 12, 'price_cents' => 250000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'der von Marco', 'receiver' => 'Barbara Berger', 'location_name' => 'Toni-Areal (TONI) 4.C12 ITZ', 'motivation' => 'AS/GS-Vorgabe für IT-Mitarbeitende', 'inspection_comment' => 'Mit Desksharing Konzept kann Menge reduziert werden.' },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 3881, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 9504, 'article_name' => 'Toyota Landcruiser', 'article_number' => 'HZj79', 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 2, 'price_cents' => 7_900_000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'Toyota', 'receiver' => 'Alex Stierli', 'location_name' => 'Toni-Areal (TONI)  01.B.01', 'motivation' => 'Privater Ausflug', 'inspection_comment' => 'nein' },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 350, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Adapter Laptop auf Konzertflügel', 'article_number' => '667788990ADS12', 'requested_quantity' => 67, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 200000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'Metzgerei Jenzer', 'receiver' => 'Pius Castelli', 'location_name' => 'Letzigrund', 'motivation' => 'Brauch das wichtig!!', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 114, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Infobildschirme Korridore', 'article_number' => nil, 'requested_quantity' => 300, 'approved_quantity' => 1, 'order_quantity' => 2, 'price_cents' => 500000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'Mehr Information', 'inspection_comment' => 'einer muss reiechen. Soviel Infos gibt es gar nicht im Toni-Areal' },
     { 'budget_period_id' => 2, 'group_id' => 8, 'user_id' => 10, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 9374, 'article_name' => 'Hammerflügel Paul McNulty nach Graf', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 3_500_000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'der von Martin', 'receiver' => 'Barbara Berger', 'location_name' => 'Toni-Areal (TONI) 4.C12 ITZ', 'motivation' => 'Für die ITZ-Partys', 'inspection_comment' => 'weiter so!!!' },
     { 'budget_period_id' => 2, 'group_id' => 4, 'user_id' => 3881, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 9504, 'article_name' => 'gabeltapler', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 9_000_000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'toyota', 'receiver' => 'Alex Stierli', 'location_name' => 'Toni-Areal (TONI)  01.B.01', 'motivation' => 'Lager bearbeitung', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 8, 'user_id' => 350, 'model_id' => 9193, 'supplier_id' => nil, 'location_id' => 8946, 'article_name' => "Blockflöte Alt in f'", 'article_number' => '67776', 'requested_quantity' => 4, 'approved_quantity' => 3, 'order_quantity' => 3, 'price_cents' => 1_256_700, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => true, 'supplier_name' => 'Musik Hug', 'receiver' => 'Ralph Wetli', 'location_name' => 'Toni-Areal (TONI) 6.A04 ', 'motivation' => 'Test', 'inspection_comment' => 'man kann auf beiden Seiten reinpusten' },
     { 'budget_period_id' => 2, 'group_id' => 10, 'user_id' => 350, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'SOFA', 'article_number' => '66', 'requested_quantity' => 1, 'approved_quantity' => 0, 'order_quantity' => 0, 'price_cents' => 87600, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'Ikea', 'receiver' => 'Mike Honegger', 'location_name' => '6.A05', 'motivation' => 'Will liegen', 'inspection_comment' => 'Keine Ikea Möbel im Hause' },
     { 'budget_period_id' => 2, 'group_id' => 4, 'user_id' => 10, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 7711, 'article_name' => 'Discobeleutung', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 80000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'der von Alex', 'receiver' => 'Barbara Berger', 'location_name' => 'Toni-Areal (TONI) 4.K01 / ITZ Shop Theke Support', 'motivation' => 'Für die Shop ITZ-Partys', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 2, 'user_id' => 114, 'model_id' => 8805, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => ' LED Profilscheinwerfer, 200W, 36° ETC Source Four LED LUSTR+ ', 'article_number' => nil, 'requested_quantity' => 33, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 348000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => 'Marco Castellano', 'location_name' => nil, 'motivation' => 'Mehr Licht im neuen Jahr', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 4, 'user_id' => 3881, 'model_id' => 9703, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'ELC Truss switch', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'neeue verkabelung', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 8, 'user_id' => 3848, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 9242, 'article_name' => 'Beamer mit Hellraumprojekterfunktion auf eckigen Rollen', 'article_number' => '4507-122 C', 'requested_quantity' => 5, 'approved_quantity' => 5, 'order_quantity' => 5, 'price_cents' => 745000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'IKEA-ALDI-LIDLGmbH & Co KG', 'receiver' => 'Ludwing von Mozart', 'location_name' => 'Toni-Areal (TONI) 07.G.01 ', 'motivation' => 'Präsentation Bundesratsempfänge', 'inspection_comment' => 'Für Dich doch alles, mein Lieber' },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 350, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Reissnagel', 'article_number' => '77', 'requested_quantity' => 150000, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 100, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => true, 'supplier_name' => 'Coop', 'receiver' => 'Mike Honegger', 'location_name' => 'Ausleihe', 'motivation' => 'testetste', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 2, 'user_id' => 3881, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'werksttwagen', 'article_number' => nil, 'requested_quantity' => 4, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 70000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'Hat der Mann in der Höle nie genug', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 10, 'model_id' => nil, 'supplier_id' => 58, 'location_id' => nil, 'article_name' => 'Speicherplatz für den Filer', 'article_number' => 'Netapp', 'requested_quantity' => 10, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 3_000_000, 'price_currency' => 'CHF', 'priority' => 'high', 'replacement' => false, 'supplier_name' => 'gib-Solutions', 'receiver' => 'Christian Wildhaber', 'location_name' => 'ITZ Serverraum', 'motivation' => 'Der Speicher ist fast voll', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 114, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'It Arbeitsplätze', 'article_number' => nil, 'requested_quantity' => 400, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 120000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => 'Marco Castellano', 'location_name' => 'Toni-Areal (TONI) 408 ', 'motivation' => 'Neue Ausbildungsgänge', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 12, 'user_id' => 3848, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'IPhone 6+', 'article_number' => 'wisst ihr sicher besser als ich', 'requested_quantity' => 14, 'approved_quantity' => 30, 'order_quantity' => 30, 'price_cents' => 60000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => false, 'supplier_name' => 'Apple', 'receiver' => 'Martin Weyermann', 'location_name' => 'Toni-Areal (TONI) 5. Stock Lehel Donath', 'motivation' => 'Empowerement aller Sekretariate', 'inspection_comment' => 'kostet nur die Hälfte' },
     { 'budget_period_id' => 2, 'group_id' => 12, 'user_id' => 114, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Bontempi_Orgel', 'article_number' => nil, 'requested_quantity' => 30, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 60000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'Umstellung auf Digitale Musik', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 350, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'fjewfewtf', 'article_number' => nil, 'requested_quantity' => 4, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'uwzeiuewqroewq', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 4, 'user_id' => 114, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Zuckerwatten magina', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 30000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'Hunger', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 10, 'user_id' => 3881, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => '10000 Ampere Anschluss', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 800000, 'order_quantity' => 800000, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'Kraftwerkkonzert', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 3881, 'model_id' => nil, 'supplier_id' => 263, 'location_id' => nil, 'article_name' => 'iPad', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 0, 'price_cents' => 105000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'Data Quest AG', 'receiver' => 'Alex Stierli', 'location_name' => 'Büro Alex', 'motivation' => 'zum mobiler Arbeiten', 'inspection_comment' => 'das hast du dir verdient!' },
     { 'budget_period_id' => 4, 'group_id' => 10, 'user_id' => 114, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Büroarbeitsplatz', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 500000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'Witzig Ergodata', 'receiver' => nil, 'location_name' => nil, 'motivation' => 'dlsüfjawelköjtewatüäwetke', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 10, 'user_id' => 114, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Rollkorpus', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 60000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'Diverse', 'receiver' => nil, 'location_name' => nil, 'motivation' => 'gfö,g,dspiogklmewopgtejstopk', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 8, 'user_id' => 114, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Bontempi orgel', 'article_number' => nil, 'requested_quantity' => 44, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 600000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'weiterbildung', 'inspection_comment' => nil },
     { 'budget_period_id' => 2, 'group_id' => 8, 'user_id' => 5824, 'model_id' => 13501, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => '2x Crown XTi 6000 in Flight Case ', 'article_number' => nil, 'requested_quantity' => 2, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'Meine Begründung', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'It Arbeitsplätze', 'article_number' => '1000010000', 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 120000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'Brack Electronics', 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => "Apple Cinema Display 20\"", 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 78000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 5824, 'model_id' => 14318, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Test Bohrmaschine', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 0, 'order_quantity' => 0, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => 'test' },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => "Apple Cinema Display 23\" oder 24\"LED glossy", 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 110000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Quato Radon Intelli Proof 21, TFT Monitor, inkl. Silver Haze Pro', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 299000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'HP LaserJet 2015 A4, 32MB RAM, 26ppm, Duplex, 1200dpi, PCL5e, PCL6, PS2', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 68000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 12, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Softwarepaket Design', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 20000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'ITZ', 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 10, 'user_id' => 5824, 'model_id' => 978, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => '7in1 Card-Reader, USB 2', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 10, 'user_id' => 5824, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => 4987, 'article_name' => 'Regal 2m hoch', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => 1, 'order_quantity' => 1, 'price_cents' => 20000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => 'Christina Nadja Wyss', 'location_name' => 'Ausstellungsstrasse, 60 (SQ) K11 Schrank 2, Gang', 'motivation' => 'test', 'inspection_comment' => 'testkommentar' },
     { 'budget_period_id' => 2, 'group_id' => 6, 'user_id' => 5824, 'model_id' => 1701, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Mikrofon - Adapter DPA DAD 6019', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 0, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'test', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 6, 'user_id' => 1363, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'Beamer lichtstark', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 120000, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => 'AVS', 'receiver' => nil, 'location_name' => nil, 'motivation' => 'darum', 'inspection_comment' => nil },
     { 'budget_period_id' => 4, 'group_id' => 6, 'user_id' => 350, 'model_id' => nil, 'supplier_id' => nil, 'location_id' => nil, 'article_name' => 'doof', 'article_number' => nil, 'requested_quantity' => 1, 'approved_quantity' => nil, 'order_quantity' => nil, 'price_cents' => 600, 'price_currency' => 'CHF', 'priority' => 'normal', 'replacement' => true, 'supplier_name' => nil, 'receiver' => nil, 'location_name' => nil, 'motivation' => 'dieso', 'inspection_comment' => nil }
    ].each do |h|
      h['organization_id'] = Procurement::Access.requesters.find_by(user_id: h['user_id']).organization_id
      r = Procurement::Request.new h
      r.save(validate: false) # skip "Budget period is over" validation
    end

    # Procurement::TemplateCategory.all.map {|x| {group_id: x.group_id, name: x.name, templates: x.templates.map {|y| {article_name: y.article_name, price: y.price.to_i} }} }
    [{ group_id: 10, name: 'Arbeitsplatz', templates: [{ article_name: 'Büroarbeitsplatz', price: 5000 }, { article_name: 'Rollkorpus', price: 600 }] },
     { group_id: 12, name: 'Arbeitsplatz IT', templates: [] },
     { group_id: 4, name: 'Av', templates: [] },
     { group_id: 12, name: 'Bildschirme', templates: [{ article_name: "Apple Cinema Display 20\"", price: 780 }, { article_name: "Apple Cinema Display 23\" oder 24\"LED glossy", price: 1100 }, { article_name: 'Quato Radon Intelli Proof 21, TFT Monitor, inkl. Silver Haze Pro', price: 2990 }] },
     { group_id: 12, name: 'Drucker', templates: [{ article_name: 'HP LaserJet 2015 A4, 32MB RAM, 26ppm, Duplex, 1200dpi, PCL5e, PCL6, PS2', price: 680 }, { article_name: 'HP LaserJet 5200dtn, S/W, Duplex, A3, 1200 dpi x 1200 dpi, 35ppm, 10/100Base-TX', price: 3500 }] },
     { group_id: 12, name: 'Eingabegeräte', templates: [{ article_name: 'Wacom intuos3 A4 regular USB Tablet mit Stift', price: 480 }] },
     { group_id: 6, name: 'Foto-Technik', templates: [{ article_name: 'A Digitalkamera Mittelformat nur Body (z.B. Nikn D7100 oder Canon EOS 700D)', price: 1500 }, { article_name: 'Digital-Kamera Mittelformat (z.B. Nikon D7100 o.ä) inkl. Objektiv (ca. 18-135mm)', price: 1500 }] },
     { group_id: 4, name: 'Licht', templates: [{ article_name: ' 2x10 Fader Wings für ETC Gio 2048', price: 226 }] },
     { group_id: 12, name: 'MitarbeiterInnen-Arbeitsplatz', templates: [{ article_name: 'Laptop: Lenovo Thinkpad X301 Intel C2 Duo 1.4GHz/64GB SSD/Wireless/BT mit 4096MB RAM', price: 2300 }] },
     { group_id: 6, name: 'Projektionstechnik', templates: [{ article_name: 'Beamer lichtstark', price: 1200 }, { article_name: 'Beamer micro mit Akku', price: 777 }, { article_name: 'Beamer Ultraportabel', price: 1000 }] },
     { group_id: 10, name: 'Regal', templates: [{ article_name: 'Regal 2m hoch', price: 200 }, { article_name: 'Regal 2m hoch', price: 150 }] },
     { group_id: 12, name: 'Scanner', templates: [{ article_name: 'Epson V500 Photo 6400 x 9600dpi, 48Bit, LED, Durchlicht bis Mittelformat', price: 420 }] },
     { group_id: 12, name: 'Software', templates: [{ article_name: 'Softwarepaket Design', price: 200 }] },
     { group_id: 12, name: 'Speicher', templates: [{ article_name: 'HardDisk LaCie 1000GB 2Big Triple', price: 980 }] },
     { group_id: 8, name: 'Tastenklassik 01', templates: [{ article_name: 'Klavier Übungsräume', price: 8000 }] },
     { group_id: 4, name: 'Video', templates: [] }
    ].each do |x|
      tc = Procurement::TemplateCategory.create! group_id: x[:group_id],
                                                 name: x[:name]
      x[:templates].each { |y| tc.templates.create! y }
    end

    if Rails.env.development?
      Procurement::BudgetPeriod.create! name: '2015',
                                        inspection_start_date: '2014-10-01',
                                        end_date: '2014-11-30'
      Procurement::BudgetPeriod.create! name: '2016',
                                        inspection_start_date: '2015-10-01',
                                        end_date: '2015-11-30'

      user_id = 1973

      parent = Procurement::Organization.find_or_create_by!(name: 'Services')
      organization = parent.children.find_or_create_by!(name: 'ITZ')
      Procurement::Access.requesters.find_or_create_by! user_id: user_id,
                                                        organization: organization

      50.times do
        r = Procurement::Request.new budget_period: Procurement::BudgetPeriod.order('RAND()').first,
                                     group: Procurement::Group.order('RAND()').first,
                                     user_id: user_id,
                                     organization_id: organization.id,
                                     article_name: Faker::Lorem.sentence,
                                     requested_quantity: (requested_quantity = rand(1..120)),
                                     approved_quantity: (approved_quantity = rand(0..1) == 0 ? rand(1..requested_quantity) : nil),
                                     price: rand(10..5000),
                                     supplier_name: Faker::Lorem.sentence,
                                     priority: ['high', 'normal'].sample,
                                     motivation: Faker::Lorem.sentence,
                                     inspection_comment: approved_quantity ? Faker::Lorem.sentence : nil,
                                     receiver: Faker::Lorem.sentence,
                                     location_name: Faker::Lorem.sentence
        r.save(validate: false) # skip "Budget period is over" validation
      end

      { 'Facility Management' => [user_id],
        'IT' => [user_id] }.each_pair do |name, ids|
        group = Procurement::Group.find_by(name: name)
        new_ids = ids - group.inspector_ids
        group.inspectors << User.find(new_ids) unless new_ids.blank?
        group.save!
      end

      # Procurement::Group.all.each do |group|
      #   attrs = {}
      #   Procurement::BudgetPeriod.all.each do |bp|
      #     attrs[bp.id] = { budget_period_id: bp.id,
      #                      amount: rand(200000..1_200_000) }
      #   end
      #   group.update_attributes!(budget_limits_attributes: attrs)
      # end

    end

  end
end
