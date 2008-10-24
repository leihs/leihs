# articles_helper.rb - a sample script for Ruby on Rails
#
# Copyright (C) 2005-2008 Masao Mutoh
#
# This file is distributed under the same license as Ruby-GetText-Package.
#
# ArticlesHelper is bound a textdomain which is bound in application.rb or 
# articles_controller.rb.
# So you don't need to call bindtextdomain here.
#

module ArticlesHelper
  def show_article(article, show_link = true)
    ret = %Q[
      <h2>#{article["title"]} (#{article["lastupdate"]})</h2>
      <pre>#{article["description"]}</pre>
    ]
    if show_link
      ret += %Q[<p style="text-align:right;margin-right:3em">#{link_to(_("Show"), :action => 'show', :id => article)}</p>]
    end
    ret
  end

  def show_list(articles)
    ret = ""
    articles.each_with_index  do |article, index|
      ret << %Q[<li>#{article["lastupdate"]}: #{link_to((h article["title"]), :action => 'show', :id => article)}</li>]
      break if index > 9
    end
    ret
  end

  def show_navigation
    articles = Article.find(:all, :order => 'lastupdate desc, id desc')
    %Q[
<div class="navigation">
<img src="/images/rails.png" width="100" height="100" />
<div class="window">
#{show_language}
</div>
<div class="window">
<h4>] + _("Ruby Links") + %Q[</h4>
<dl>
<li><a href="http://www.ruby-lang.org/">Ruby</a></li>
<li><a href="http://rubyforge.org/projects/gettext/">Ruby-GetText-Package</a></li>
<li><a href="http://wiki.rubyonrails.com/">Ruby on Rails Wiki</a></li>
</dl>
</div>
<div class="window">
<h4>] + _("Old articles") + %Q[</h4>
<p>
<dl>
#{show_list(articles)}
</dl>
</p>
</div>
</div>
    ]
  end
end
