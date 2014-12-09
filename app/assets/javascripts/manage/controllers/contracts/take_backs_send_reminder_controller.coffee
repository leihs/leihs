class window.App.TakeBacksSendReminderController extends Spine.Controller

  events:
    "click [data-send-takeback-reminder]": "send"
  
  send: (e)=>
    trigger = $ e.currentTarget
    takeBack = App.Visit.findOrBuild trigger.closest("[data-id]").data()
    takeBack.remind()
    line = trigger.closest(".line")
    if line.length
      line.find(".latest-reminder-cell").html App.Render "manage/views/take_backs/reminder_send"
    trigger.closest(".dropdown").hide()