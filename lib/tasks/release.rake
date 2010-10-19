namespace :release do 

  desc "Export a specific tag to a directory, then cd into that directory, clean up and package the result"
  task :package do
    tag = ENV['tag']
		
		if tag.nil?
			puts "ERROR: A tag must be set, e.g. rake release:package tag=2.0b3"
		else
      `git clone git://github.com/psy-q/leihs.git leihs-#{tag}`
      Dir.chdir("leihs-#{tag}")
      matching_tag = `git tag -l #{tag}`
      if matching_tag.blank?
        puts "ERROR: The tag #{tag} does not exist. Available tags are:"
        tags = `git tag`
        puts tags
      else
        `git checkout #{tag}`

        # Copy latest release packaging tasks to a potentially old dir
        `git checkout master lib/tasks/release.rake`

        # Clean up the exported version
		    `rake release:clean`
        Dir.chdir("..")
        `zip -r leihs-#{tag}.zip leihs-#{tag}`
        `tar cfz leihs-#{tag}.tar.gz leihs-#{tag}`
      end
    end

  end

  desc "Clean up the current directory for release packaging"
  task :clean do
  # remove temp files, change config files so they don't
  # contain any silliness etc.
	
    puts "Removing Capistrano deployment recipes"
    rm_r "config/deploy" rescue nil
    rm "config/deploy.rb" rescue nil
    rm "Capfile" rescue nil

    puts "Removing mike files"
    rm "app/models/inventory_import/mike/categories.csv" rescue nil
    rm "app/models/inventory_import/mike/inventory.csv" rescue nil

    puts "Renaming critical config files to .example"
    `mv config/database.yml config/database.yml.example`
    `mv config/ferret_server.yml config/ferret_server.yml.example`
    `mv config/mongrel_cluster.yml config/mongrel_cluster.yml.example`


    puts "Removing log file dir"
    rm_r "log" rescue nil

    puts "Removing index dir"
    rm_r "index" rescue nil

    puts "Removing our own rails version"
    rm_r "vendor/rails" rescue nil

    puts "Removing unnecessary documentation."
    rm_r "doc/plugins" rescue nil

    puts "Removing local gems"
    rm_r "vendor/gems" rescue nil

    puts "Removing 'other' directory"
    rm_r "other" rescue nil


    puts "Generating latest locale files"
    `rake makemo`
   
    puts "Removing hkb directory"
    rm_r "hkb" rescue nil

    generate_docs
    
    puts "Recreating tmp directories"
    rm_r "tmp" rescue nil
    mkdir "tmp"
    mkdir "tmp/sessions"
    mkdir "tmp/cache"
    mkdir "tmp/pids"
    mkdir "tmp/attachment_fu"
    mkdir "tmp/sockets"

    puts "Removing specs, stories and tests"
    rm_r "spec" rescue nil
    rm_r "stories" rescue nil
    rm_r "test" rescue nil

    puts "Removing backup files"
    # Recursively looks for files ending in ~ and kills them
    Dir['**/*~'].each do |fn|
      rm fn rescue nil
    end

    puts "Removing git directory"
    rm_r ".git" rescue nil

  end

  desc "Generate HTML and PDF documentation using ASCIIdoc"
  task :gendoc do

    generate_docs

  end


  
  def generate_docs
    # You need asciidoc and dblatex installed for this to work
    ["user", "admin"].each do |recipient|
      puts "Generating #{recipient} documentation"
      docu = "doc/#{recipient}_guide" 
      `asciidoc -a toc -o #{docu}.html #{docu}.txt`
      `asciidoc -b docbook -a toc -o #{docu}.xml #{docu}.txt `
      `dblatex --pdf #{docu}.xml -o #{docu}.pdf`
      rm "#{docu}.xml" rescue nil
      rm "#{docu}.fo" rescue nil
    end
  end 

end
