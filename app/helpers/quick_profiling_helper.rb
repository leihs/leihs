module QuickProfilingHelper
  # Output profiling/timing information
  #
  #   <%
  #      include QuickProfilingHelper
  #
  #      t_init       # this is needed for initialization
  #      t_tresh 0.03 # log treshold
  #    %>
  #      ...
  #   <% t "1"; do some stuff %>
  #   <% t "2"; do different stuff %>
  #
  # will output time elapsed between step "1" and step "2" if it was longer
  # than 0.03s.
  #
  # The "t" method can also be used inside controllers etc.
  #
  def t(step_id)
    now = Time.now
    diff = now - @t_last
    if diff > @t_tresh
      puts "#{step_id} #{diff}"
    end
    @t_last = now
  end

  # see #t
  #
  def t_init
    @t_last = Time.now
  end

  # see #t
  #
  def t_tresh( treshold )
    @t_tresh = treshold
  end
end
