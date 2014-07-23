###
  
  License

###

class window.App.License extends window.App.Item

  @configure "License"
  @belongsTo "software", "App.Software", "model_id"

  licenseInformation: ->
    _.compact(
      [ @osInformation(),
        @licenseTypeInformation(),
        @properties.total_quantity ]
    ).join ", "

  osInformation: ->
    if @properties.operating_system
      _.map(@properties.operating_system, (os) -> _jed App.License.formatString os).join ", "

  licenseTypeInformation: ->
    _jed App.License.formatString @properties.license_type

  @formatString: (s) =>
    capitalizeEachWord = (s) =>
      s.replace /(?:^|\s)\S/g, (s) -> s.toUpperCase()
    capitalizeEachWord _.string.humanize s
