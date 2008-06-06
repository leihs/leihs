namespace :active_fpdf do
  ACTIVE_FPDF_ROOT = "#{RAILS_ROOT}/vendor/plugins/active_fpdf"
  ACTIVE_FPDF_TEMPLATES = ACTIVE_FPDF_ROOT + "/templates"
  TEMPLATE_FILE_FOR_PDF = "fpdf_layout.rb"

  desc "Initialize all PDF views with ActiveFPDF"
  task :init => :environment do
    dir_fonts = "#{RAILS_ROOT}/app/views/fonts"
    Dir.mkdir(dir_fonts) unless File.directory?(dir_fonts)
    
    src_fpdf_file = ACTIVE_FPDF_TEMPLATES + "/" + TEMPLATE_FILE_FOR_PDF
    dest_fpdf_file = "#{RAILS_ROOT}/app/helpers" + "/" + TEMPLATE_FILE_FOR_PDF
    FileUtils.copy(src_fpdf_file, dest_fpdf_file) unless FileTest.exists?(dest_fpdf_file)
  end
  
  # TODO
  desc "TODO Create all PDF views with ActiveFPDF"
  task :create_all => :init do    
    Dir["#{RAILS_ROOT}/app/views/*"].each do |fname|
      # delete from layout and fonts
      dir_pdfs = fname + "/pdfs"
      Dir.mkdir(dir_pdfs) unless File.directory?(dir_pdfs)
      dest_show_file = dir_pdfs + "/show.rfpdf" 
      dest_index_file = dir_pdfs + "/index.rfpdf" 
      src_show_file = ACTIVE_FPDF_TEMPLATES + "/show.rfpdf" 
      src_index_file = ACTIVE_FPDF_TEMPLATES + "/index.rfpdf" 
      FileUtils.copy(src_show_file, dest_show_file) unless FileTest.exists?(dest_show_file)
      FileUtils.copy(src_index_file, dest_index_file) unless FileTest.exists?(dest_index_file)
    end  
  end
  
  # TODO
  desc "TODO Create a PDF view with ActiveFPDF"
  task :create => :init do
    
  end
end