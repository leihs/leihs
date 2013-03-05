#!/bin/bash --login

mkdir -p $WORKSPACE/tmp/capybara&#xd;
rm -rf $WORKSPACE/log &amp;&amp; mkdir -p $WORKSPACE/log&#xd;
rm -f $WORKSPACE/tmp/*.mysql&#xd;
rm -f $WORKSPACE/tmp/*.sql&#xd;
mkdir -p $WORKSPACE/tmp/html&#xd;
command -v rvm &gt;/dev/null 2&gt;&amp;1 &amp;&amp;  rvm use 1.9.3&#xd;
bundle exec rake madek:test:drop_ci_dbs --trace
