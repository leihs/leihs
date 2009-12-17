class InventoryImport::ImportIthelp

  attr_accessor :messages

  def start(max = 999999)
    connect_dev
    self.messages = []
    #inventar = InventoryImport::ItHelp.find(:all,	:order => 'Inv_Serienr')

    # Only take things from group 262 ("ready for Leihs 2 Import")
    inventar = InventoryImport::ItHelp.find_by_sql("select * from hwInventar where Inv_Serienr in( select hwId from groupEntry where groupId = 262 )")
    count = 0

    counters = { :accepted => 0, :rejected => 0 }

    accepted_items = []
    inventar.each do |item|

      itemname = "#{item.Inv_Serienr} - #{item.Art_Bezeichnung}"

      # Only ITZ items, we don't want to import anything else anymore
      # This check is still needed despite the explicit grouping above, because some people group items
      # for export even though they belong to AVZ
      if item and ["ITZV","ITZ", "ITZS"].include?(item.Inv_Abteilung)

        # Lots of reasons for not importing items follow
        if item.retired?
          # Skipping retired items for now (2009-09) until ITZ decides whether they want
          # them imported at all.
          next
        end

        if item.Inv_Abteilung =~ /^avz/i 
          puts "!: #{itemname} is from AVZ and we're past the AVZ import cutoff date, won't import"
          counters[:rejected] += 1
          next
        end

        if item.Inv_Abteilung =~ /.*other.*/i
          puts "!: #{itemname} is from 'other', won't import "
          counters[:rejected] += 1
          next
        end

        
        attributes = {
          :name => item.Art_Bezeichnung,
          :manufacturer => item.Art_Hersteller,
        }
        model = Model.find_or_create_by_name attributes
        model.update_attributes(attributes)

        category = Category.find_or_create_by_name :name => item.Art_Gruppe_2
        category.models << model unless model.id == 0 || category.models.include?(model) # OPTIMIZE 13** avoid condition, check uniqueness on ModelLink

        checkdate = 0
        checkdate = Date.new(item.Inv_geprueft) unless item.Inv_geprueft.blank?

        item_attributes = {
          :inventory_code => (item.Inv_Abteilung + item.Inv_Serienr.to_s),
          :serial_number => item.Art_Serienr,
          :model => model,
          :location => get_location(item.Stao_Abteilung, item.Stao_Raum),
          :owner => get_owner("ITZ"),
          :inventory_pool => (item.rental == 'yes') ? get_owner(item.Stao_Abteilung) || get_owner("ITZ") : nil,
          :last_check => checkdate,
          :required_level => AccessRight::CUSTOMER,
          :retired => item.Ausmuster_Dat,
          :retired_reason => item.Ausmuster_Grund,
          :invoice_number => item.Lief_Rechng_Nr,
          :invoice_date => item.Lief_Rechng_Dat,
          :is_incomplete =>  false,
          :is_broken => false,
          :is_borrowable => item.rental == 'yes',
          :price => item.Art_Wert,
          :supplier => Supplier.find_or_create_by_name({ :name => item.Lief_Firma || item.Lief_Code })
        }

				preexisting = false
				if Item.find_by_inventory_code(item_attributes[:inventory_code])
					preexisting = true
					puts "Item " + item_attributes[:inventory_code] + "(" + item_attributes[:model].name  + ")" + " already exists in target, skipping"
				end

        # No need to create the item if it's already retired
				# Also, skip anything we've already imported during an earlier import
        unless item.retired? or (preexisting == true)
          i = Item.find_or_create_by_inventory_code item_attributes
          i.update_attributes(item_attributes)

          #Add misc. stuff as notes.
          unless item.Art_Zusatz.blank? || item.Art_Zusatz == "-"
            #puts "Artikel Zusatz: #{i.id} - #{item.Art_Zusatz}"
            i.log_history(item.Art_Zusatz, nil)
          end

          unless item.Eingebaut_in.blank?
            #puts "Eingebaut: #{i.id} - #{item.Eingebaut_in}"
            i.log_history("Eingebaut in: #{item.Eingebaut_in}", nil)
          end

          #If the item now belongs to a different Model - Remap existing contract lines to the new model.
          i.contract_lines.each do | line |
            line.update_attributes(:model => model)
          end

          accepted_items << i
          counters[:accepted] += 1

          count += 1
          break if count == max
        else
          # Used to be: Delete retired item
        end
      else
        add_message "#{item.Inv_Abteilung} Items are not being imported, ignoring #{item.Inv_Serienr.to_s}" if item

      end

    end

    puts "#{counters[:accepted]} items accepted, #{counters[:rejected]} items rejected."

    puts "#### The following items were imported/updated:"
    accepted_items.each do |i|
      puts i
    end
  end


  def add_message(text)
    puts text
    self.messages << text
  end

  # TODO import building, room and shelf
  def get_location(inventory_pool_name, location_room)
    return Location.find_or_create(:room => location_room)
  end

  def get_owner(dept)
    o = InventoryPool.find_by_name(dept[0..2])
    o = InventoryPool.find_by_name(use_new_name(dept[0..2])) unless o
    o
  rescue

  end




  def use_new_name_for(inv_abt)
  #  puts "Did the name change for: #{inv_abt}?"
    return "VMK" if inv_abt.upcase == "SNM"
    return "VMK" if inv_abt.upcase == "VNM"
    return "VIAD" if inv_abt.upcase == "IAD"
    return "VTO" if inv_abt.upcase == "TMS"
    inv_abt
  end




####################################################################

  def connect_dev
    InventoryImport::ItHelp.establish_connection(it_help_dev)
  end

  def it_help_dev
    {   :adapter => 'mysql',
        :host => '127.0.0.1',
        :database => 'ithelp_development',
        :encoding => 'latin1',
        :username => 'leihs',
        :password => 'leihs' }
  end

####################################################################

  def connect_prod
    InventoryImport::ItHelp.establish_connection(it_help_prod)
  end

  def it_help_prod
    {   :adapter => 'mysql',
        :host => '195.176.254.49',
        :database => 'ithelp_alt',
        :encoding => 'utf8',
        :username => 'helpread',
        :password => '2read.0nly!' }
  end


end
