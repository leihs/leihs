require_relative('logger')
require('csv')
# require('pry')

class CSVParser
  def initialize(path_to_file)
    file_contents = File.open(path_to_file, "r").read
    if ! file_contents.valid_encoding?
      log('fixing encoding', :info, true)
      file_contents = \
        file_contents
        .encode("UTF-16be", :invalid=>:replace, :replace=>"?")
        .encode('UTF-8')
    end
    @file_contents = file_contents
  end

  def for_each_row(csv_parser = self, &block)
    reset_counters!
    enhanced_block = Proc.new do |row|
      count_row!
      block.call(row)
    end
    CSV.parse(@file_contents, headers: :first_row, &enhanced_block)
    log("#{@done_counter} out of #{@to_do_counter} done", :info, true)
    reset_counters!
  end

  def row_success!
    @done_counter += 1
  end

  private

  def count_row!
    @to_do_counter += 1
  end

  def reset_counters!
    @to_do_counter = 0
    @done_counter = 0
  end
end
