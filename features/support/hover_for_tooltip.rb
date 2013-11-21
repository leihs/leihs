def hover_for_tooltip(el)
  sleep(0.33) # wait for potential previous hovers
  find("body").click
  find("body").hover
  el.hover
  sleep(0.51) # popup delay
  el.hover
  sleep(0.44) # wait for the css transition
  find(".tooltipster-default", match: :first)
end