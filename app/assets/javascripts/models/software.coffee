###

  Software

###

class window.App.Software extends window.App.Model

  @configure "Software"
  @hasMany "licenses", "App.License", "model_id"
