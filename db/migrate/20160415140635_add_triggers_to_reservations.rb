class AddTriggersToReservations < ActiveRecord::Migration

  STATES = {
    'unsubmitted' => ['unsubmitted', 'submitted'],
    'submitted' => ['submitted', 'approved', 'rejected'],
    'approved' => ['approved', 'signed'],
    'rejected' => ['rejected'],
    'signed' => ['signed', 'closed'],
    'closed' => ['closed']
  }

  def up
    ['insert', 'update'].each do |action|
      execute <<-SQL
        CREATE TRIGGER before_#{action}_check_status_for_contract_id_null
        BEFORE #{action.upcase} ON reservations
        FOR EACH ROW
        BEGIN
          IF (NEW.status IN ('signed', 'closed') AND NEW.contract_id IS NULL)
          THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'reservations: unallowed status for contract_id = NULL';
          END IF;
        END;
      SQL

      execute <<-SQL
        CREATE TRIGGER before_#{action}_check_status_for_contract_id_not_null
        BEFORE #{action.upcase} ON reservations
        FOR EACH ROW
        BEGIN
          IF (NEW.status IN ('unsubmitted', 'submitted', 'approved', 'rejected') AND NEW.contract_id IS NOT NULL)
          THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'reservations: unallowed status for contract_id != NULL';
          END IF;
        END;
      SQL
    end

    STATES.each_pair do |orig_state, allowed_states|
      execute <<-SQL
        CREATE TRIGGER before_update_check_status_transition_from_#{orig_state}
        BEFORE UPDATE ON reservations
        FOR EACH ROW
        BEGIN
          IF (OLD.status = '#{orig_state}' AND NEW.status NOT IN (#{allowed_states.map {|s| "'#{s}'"}.join(', ')}))
          THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'reservations: unallowed state transition for #{orig_state}';
          END IF;
        END;
      SQL
    end
  end

  def down
    ['insert', 'update'].each do |action|
      execute "DROP TRIGGER before_#{action}_check_status_for_contract_id_null;"
      execute "DROP TRIGGER before_#{action}_check_status_for_contract_id_not_null;"
    end

    STATES.keys.each do |state|
      execute "DROP TRIGGER before_update_check_status_transition_from_#{state};"
    end
  end
end
