# Copy custom assets
puts "\nInstalling Assets"
for path in [ ['javascripts', 'ext_datetime.js'],
              ['javascripts', 'ext_searchfield.js'],
              ['stylesheets', 'ext_scaffold.css'],
              ['images', 'ext_scaffold', 'arrowRight.gif'],
              ['images', 'ext_scaffold', 'arrowLeft.gif'] ]
  source = File.join(File.dirname(__FILE__),'assets',*path)
  destination = File.join(RAILS_ROOT,'public',*path)
  print "  #{path.join('/')} "
  if File.exists?(destination)
    if FileUtils.cmp(source, destination)
      puts "identical"
    else
      print "exits, overwrite [yN]?"
      if gets("\n").chomp.downcase.first == 'y'
        FileUtils.cp source, destination
      else
        puts "    ...skipped"; next
      end
    end
  else
    puts "create"
    FileUtils.mkdir_p File.dirname(destination)
    FileUtils.cp source, destination
  end
end

puts <<_MSG

You now need to download the Ext Javascript framework from

http://extjs.com/download

and unzip it into "#{RAILS_ROOT}/public/ext" if you have not done so yet.
The latest Ext version Ext_scaffold was tested against is 2.0.1, available via

http://extjs.com/deploy/ext-2.0.1.zip

_MSG
