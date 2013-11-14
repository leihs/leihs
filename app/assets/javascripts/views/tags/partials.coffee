$.views.tags
  
  partial: (args...) -> 
    args[1] = {} unless args[1]?
    App.Render.apply @, args