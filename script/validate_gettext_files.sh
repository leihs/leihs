#!/bin/bash

which msgcat >> /dev/null
if [ $? -ne 0 ]
then
  echo "FATAL: Gettext is not installed, the 'msgcat' tool is missing or can't be found in your PATH. Install gettext or make sure the msgcat binary is in your PATH."
  exit 1
fi


# Function to run msgcat on a .po or .pot file. msgcat will fail fatally
# if it encounters duplicate string definitions or other problems with your file.
# If there are no problems, it will cat the content of the file to STDOUT, so let's
# redirect that noise to null.
function check_file {
  msgcat $1 >> /dev/null
  if [ $? -ne 0 ]
  then
    echo "GETTEXT FATAL ERROR: $1 does not validate."
    exit 1
  fi
}

# Validate the files
check_file locale/leihs.pot
for file in locale/**/leihs.po
do
  check_file $file
done
