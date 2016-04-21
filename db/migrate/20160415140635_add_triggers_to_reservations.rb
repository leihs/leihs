class AddTriggersToReservations < ActiveRecord::Migration

  def up
    #######################################################
    # ENABLE CREATION OF TRIGGERS
    execute 'set global log_bin_trust_function_creators=1;'
    #######################################################

    ['insert', 'update'].each do |action|
      execute <<-SQL
        CREATE TRIGGER before_#{action}_check_status_for_contract_id
        BEFORE #{action.upcase} ON reservations
        FOR EACH ROW
        BEGIN
          IF ((NEW.status IN ('unsubmitted', 'submitted', 'approved', 'rejected') AND NEW.contract_id IS NOT NULL)
              OR
              (NEW.status IN ('signed', 'closed') AND NEW.contract_id IS NULL))
          THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'reservations: unallowed status depending on contract_id';
          END IF;
        END;
      SQL
    end
  end

  def down
    ['insert', 'update'].each do |action|
      execute "DROP TRIGGER before_#{action}_check_status_for_contract_id;"
    end
  end
end
