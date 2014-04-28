class FixSignedContractsUniqueStartDate < ActiveRecord::Migration
  def change

    # select all signed contracts which all lines are returned
    contracts = Contract.signed.all.select {|c| c.lines.all? {|cl| cl.returned_date }}
    # set a unique start_date and close the contract
    contracts.each do |contract|
      min_start_date = contract.lines.map(&:start_date).min
      contract.lines.update_all(start_date: min_start_date)
      contract.close
    end

    # select all signed contracts which lines don't have unique start_date
    contracts = Contract.signed.all.select {|c| c.lines.map {|cl| cl.start_date }.uniq.size > 1 }
    # set a unique start_date, keep the contract as signed
    contracts.each do |contract|
      min_start_date = contract.lines.map(&:start_date).min
      contract.lines.update_all(start_date: min_start_date)
    end

    still_invalid_signed_contracts = Contract.signed.select {|c| not c.valid? }
    unless still_invalid_signed_contracts.empty?
      puts still_invalid_signed_contracts.inspect
      raise "Not all signed contracts are valid! Check your data:"
    end

  end
end
