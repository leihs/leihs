#!/bin/sh

export LC_ALL="ja_JP.eucJP"; 
export LANG="ja_JP.eucJP"; 
rake rebuilddb
for target in test_*.rb
do
ruby  -I../lib $target
done
exit
cd rails
rake -I../../lib test
cd ..
