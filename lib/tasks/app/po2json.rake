namespace :app do

  namespace :i18n do

    desc "Convert all .po files to json"
    task :po2json => :environment do
      puts "[START] Converting all .po files from locale/[LANG]/leihs.po to app/assets/javascripts/i18n/locale/[LANG].js"
      
      Dir.glob("locale/**/*.po").each do |path|
        lang = path.split("/")[1]
        outputPath = "app/assets/javascripts/i18n/locale/#{lang.gsub(/_/, "-")}.js"
        basePath = "app/assets/javascripts/i18n/formats/#{lang.gsub(/_/, "-")}.js"
        puts "node app/node/po2json.js #{path} #{outputPath} #{basePath}"
        `node app/node/po2json.js #{path} #{outputPath} #{basePath}`
      end
      
      puts "[END] finished .po file conversion"
    end
  end
end