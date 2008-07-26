require 'test/unit'
require 'fileutils'

# This is more or less what I would refer to as an integration test. It tests
# the complete process from project creation to running the generated functional
# tests.
# To run the full test suite, an EXTJS_LOCATION environment variable must be 
# set to point to a filesystem path with the extracted Ext JS framework to be
# tested against 
class ExtScaffoldTest < Test::Unit::TestCase

  def test_project_creation_and_demo_scaffold
    # generate demo Rails project
    `rails ext_scaffold_demo --force --database=sqlite3`
    assert_equal 0, $?

    # install ext_scaffold plugin
    FileUtils.mkdir_p './ext_scaffold_demo/vendor/plugins/ext_scaffold'
    FileUtils.cp_r %w(init.rb install.rb uninstall.rb ./assets ./generators ./lib ./tasks), './ext_scaffold_demo/vendor/plugins/ext_scaffold'
    `cd ext_scaffold_demo/vendor/plugins/ext_scaffold; ruby ../../../script/runner ./install.rb`
    assert_equal 0, $?

    # generate sample scaffold
    `cd ext_scaffold_demo; ruby script/generate ext_scaffold Post title:string body:text published:boolean visible_from:datetime visible_to:date`
    assert_equal 0, $?

    # migrate DB
    `cd ext_scaffold_demo; rake db:migrate`
    assert_equal 0, $?

    # inject EXT into demo project if available
    if ENV['EXTJS_LOCATION'] && File.directory?(ENV['EXTJS_LOCATION'])
      ext_base_path = './ext_scaffold_demo/public/ext'
      FileUtils.ln_s ENV['EXTJS_LOCATION'], ext_base_path
      # check availability of neccessary files
      %w(examples/shared/icons/fam/add.gif examples/shared/icons/fam/delete.gif examples/shared/icons/fam/cog.png resources/images/default/shared/glass-bg.gif).each do |f|
        assert File.readable?(File.join(ext_base_path,f)), "#{f} is not availble in your Ext installation"
      end
    else
      flunk "Test suite can not be completed without EXTJS_LOCATION pointing to valid Ext JS installation"
    end
    
    # run functional tests on generated scaffold
    `cd ext_scaffold_demo; rake`
    assert_equal 0, $?

  ensure
    FileUtils.rm_r './ext_scaffold_demo'
  end

end
