#!/bin/sh

export LC_ALL="ja_JP.UTF-8"; 
export LANG="ja_JP.UTF-8"; 
rake rebuilddb
for target in test_*.rb
do
ruby  -I../lib $target
done
exit
cd rails
rake -I../../lib test
cd ..
