###

App.Tooltip

This script provides functionalities for tooltips.

Either use the title tag in an element with the class "tooltip"
or create an Tooltip with new App.Tooltio(options).

###

class App.Tooltip

   constructor: (options)->

      $(options.el).tooltipster
         animation: 'fade',
         arrow: true,
         content: options.content,
         delay: 150,
         fixedWidth: 0,
         maxWidth: 0,
         interactive: false,
         interactiveTolerance: 350,
         offsetX: 0,
         offsetY: 0,
         onlyOne: true,
         position: 'top',
         speed: 150,
         timer: 0,
         touchDevices: true,
         trigger: 'hover',
         updateAnimation: true

      $this.data("tooltipster").addClass options.className if options.className?

      $(options.el).tooltipster "show"

window.App.Tooltip = App.Tooltip

jQuery -> $(document).on "mouseenter", ".tooltip[title]", (e)-> 
   new App.Tooltip
      el: $(this)
      content: App.Render("tooltips/default", {content: $(this).attr("title")})