def hover_for_tooltip(target)
  sleep(0.99) # wait for potential previous tooltips
  find("footer").click # move mouse somewhere else to ensure its currently not over the target
  target.click
  target.click
  sleep(0.99) # wait for the css transition
  all(".tooltipster-content") # there should be just one
end