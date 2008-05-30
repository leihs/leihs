#!/bin/sh

export LC_ALL="ja_JP.eucJP"; 
export LANG="ja_JP.eucJP"; 
rake rebuilddb
for target in test_*.rb
do
/usr/java/jruby/bin/jruby  -I../lib $target
done
cd rails
/usr/java/jruby/bin/jruby /usr/java/jruby/bin/rake -I../../lib test
cd ..
