namespace :release do 

  desc "Clean up the current directory for release packaging"
  task :clean do
  # remove temp files, change config files so they don't
  # contain any silliness etc.
	
    puts "Removing Capistrano deployment recipes"
    rm_r "config/deploy" rescue nil
    rm "config/deploy.rb" rescue nil
    rm "Capfile" rescue nil


    puts "Renaming critical config files to .sample"
    `mv config/database.yml config/database.yml.sample`
    `mv config/ferret_server.yml config/ferret_server.yml.sample`
    `mv config/mongrel_cluster.yml config/mongrel_cluster.yml.sample`


    puts "Removing log file dir"
    rm_r "log" rescue nil

    puts "Removing index dir"
    rm_r "index" rescue nil

    puts "Generating latest locale files"
    `rake makemo`

    puts "Generating user documentation"
    # You need asciidoc and docbook2pdf installed for this to work
    `asciidoc -a toc -o doc/admin_guide.html doc/admin_guide.txt`
    `asciidoc -b docbook -a toc -o doc/admin_guide.xml doc/admin_guide.txt `
    `db2pdf doc/admin_guide.xml -o doc`
    rm "doc/admin_guide.xml" rescue nil
    rm "doc/admin_guide.fo" rescue nil

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

    puts "Removing Subversion directories"
    Dir['**/.svn'].each do |fn|
      rm fn rescue nil
    end

  end

end
