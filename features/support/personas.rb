module Persona
  extend self
  
  def get(name)
    User.where(:login => name.downcase).first
  end
  
  def create(name)
    name = name.to_s
    if FileTest.exist? "features/personas/#{name.downcase}.rb"
      persona = Persona.get(name)
      if persona.blank?
        require Rails.root+"features/personas/#{name.downcase}.rb"
        Persona.const_get(name.camelize).new
        return Persona.get(name)
      else
        return persona
      end
    else 
      raise "Persona #{name} does not exist"
    end
  end
  
  def create_all
    Dir.glob(File.join(Rails.root, "features/personas", "**", "*"))
      .select {|x| not File.directory? x}
      .each do |file|
        Persona.create File.basename(file, File.extname(file))
    end
  end
end
