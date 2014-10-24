module EvalHelpers

  private

  def exact_match? v
    [
        "Faker::Commerce.product_name",
        "Faker::Lorem.sentence",
        "Faker::Lorem.paragraph",
        "Faker::Lorem.word",
        "Faker::Name.last_name",
        "Faker::Name.first_name",
        "Faker::Internet.email",
        "Faker::Address.street_address + \", \"",
        "[true, false].sample",
        "Date.today",
        "Date.yesterday",
        "%w(windows linux mac_os_x).sample(rand(1..2)).join(',')",
        "%w(concurrent site_license multiple_workplace).sample"
    ]
    .include?(v)
  end

  def regex_match? v
    [
        /^rand\(\d{1}\.\.\d{,3}\)$/,
        /^rand\(\d{,3}\)$/,
        /^Time.now [-+] (\d{,3}|rand\(\d{1}\.\.\d{,3}\))\.(days?|months?)$/,
        /^Date\.(today|yesterday) [-+] (\d{,3}|rand\(\d{1}\.\.\d{,3}\))\.(days?|months?)$/
    ]
    .any? { |r| r.match v }
  end

  def allowed_code? v
    exact_match? v or regex_match? v
  end

  def nilify_empty_string v
    v unless v.empty?
  end

  public

  def substitute_with_eval v
    match = /(#\{(.*)\})/.match(v)
    if match
      if allowed_code?($2)
        v.gsub $1, eval($2).to_s
      else
        raise "Not allowed code string: #{v}"
      end
    else
      v
    end
  end

  def hashes_with_evaled_and_nilified_values table
    table.hashes.map do |h|
      h.each { |k, v| h[k] = nilify_empty_string(substitute_with_eval v) }
    end
  end

end
