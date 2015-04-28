namespace :app do

  namespace :i18n do

    desc 'Convert all .po files to json'
    task po2json: :environment do
      puts '[START] Converting all .po files from locale/[LANG]/leihs.po to app/assets/javascripts/i18n/locale/[LANG].js'
      
      Dir.glob('locale/**/*.po').each do |path|
        lang = path.split('/')[1]
        outputPath = "app/assets/javascripts/i18n/locale/#{lang.gsub(/_/, "-")}.js"
        basePath = "app/assets/javascripts/i18n/formats/#{lang.gsub(/_/, "-")}.js"
        puts "node app/node/po2json.js #{path} #{outputPath} #{basePath}"
        `node app/node/po2json.js #{path} #{outputPath} #{basePath}`
      end
      
      puts '[END] finished .po file conversion'
    end

   desc 'Try to extract Jed strings from our views'
   task :extract_jed_strings do

      not_already_translated = []
      candidates = `grep -hroP '_jed(.*)' app/ | sort | uniq | grep -o '(.*)' | sed -e \"s/'/\\"/g\" | sed -e 's/(//g' |  sed -e 's/)//g'`.split("\n")
      candidates.each do |candidate|
        if `grep -c '#{candidate}' app/views/javascript_strings.html.erb`.chomp.to_i == 0 and\
           `grep -c '#{candidate}' locale/leihs.pot`.chomp.to_i == 0
          not_already_translated << candidate
        end
      end

      puts "== Untranslated strings (please add to app/views/javascript_strings.html.erb if they look OK)\n\n"
      puts "   DANGER: Do not use variables or string interpolation unless you provide a valid variable for it!\n\n"
      not_already_translated.each do |nat|
        puts "<% _(#{nat}) %>"
      end
    end 
  
  end
end
