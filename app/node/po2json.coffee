sourcePath = process.argv[2]
outputPath = process.argv[3]
basePath = process.argv[4]
po2json = require "../../vendor/node/po2json.js"
fs = require 'fs'

po2json.parse sourcePath, (result)->
  base = fs.readFileSync fs.realpathSync(basePath), 'utf8'
  base ?= ""
  result = "if (window.i18n == undefined) window.i18n = {};\n#{base}\nwindow.i18n.locale_data = #{result}"
  console.log "write file"
  fs.writeFile outputPath, result, (err)->
    if err
      console.log err
    else
      console.log "po file converted and saved to #{outputPath}"
