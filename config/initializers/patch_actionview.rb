# Take out if Rails upgrade to 2.1 with contribution (ActionPack)
# Patch http://dev.rubyonrails.org/ticket/11537
module ActionView
  module Helpers
    
    module TextHelper
      silence_warnings do
        AUTO_LINK_RE = %r{
                        (                          # leading text
                          <\w+.*?>|                # leading HTML tag, or
                          [^=!:'"/]|               # leading punctuation, or
                          ^                        # beginning of line
                        )
                        (
                          (?:https?://)|           # protocol spec, or
                          (?:www\.)                # www.*
                        )
                        (
                          [-\w]+                   # subdomain or domain
                          (?:\.[-\w]+)*            # remaining subdomains or domain
                          (?::\d+)?                # port
                          (?:/(?:(?:[~\w\+@%=\(\)-]|(?:[,.;:'][^\s$]))+)?)* # path
                          (?:\?[\/+\w\+@%&=.;-]+)?     # query string ## NOTE patch: \/+ 
                          (?:\#[\w\-]*)?           # trailing anchor
                        )
                        ([[:punct:]]|<|$|)       # trailing text
                       }x
      end
    end
    
    module UrlHelper

        def convert_options_to_javascript!(html_options, url = '')
          confirm, popup = html_options.delete("confirm"), html_options.delete("popup")

          method, href, target = html_options.delete("method"), html_options['href'], html_options['target']

          html_options["onclick"] = case
            when popup && method
              raise ActionView::ActionViewError, "You can't use :popup and :method in the same link"
            when confirm && popup
              "if (#{confirm_javascript_function(confirm)}) { #{popup_javascript_function(popup)} };return false;"
            when confirm && method
              "if (#{confirm_javascript_function(confirm)}) { #{method_javascript_function(method)} };return false;"
            when confirm
              "return #{confirm_javascript_function(confirm)};"
            when method
              "#{method_javascript_function(method, url, href, target)}return false;"
            when popup
              popup_javascript_function(popup) + 'return false;'
            else
              html_options["onclick"]
          end
        end
      
        def method_javascript_function(method, url = '', href = nil, target = nil)
          action = (href && url.size > 0) ? "'#{url}'" : 'this.href'
          submit_function =
            "var f = document.createElement('form'); f.style.display = 'none'; " +
            "this.parentNode.appendChild(f); f.method = 'POST'; f.action = #{action};"
          submit_function << " f.target = '#{target}';" if target

          unless method == :post
            submit_function << "var m = document.createElement('input'); m.setAttribute('type', 'hidden'); "
            submit_function << "m.setAttribute('name', '_method'); m.setAttribute('value', '#{method}'); f.appendChild(m);"
          end

          if protect_against_forgery?
            submit_function << "var s = document.createElement('input'); s.setAttribute('type', 'hidden'); "
            submit_function << "s.setAttribute('name', '#{request_forgery_protection_token}'); s.setAttribute('value', '#{escape_javascript form_authenticity_token}'); f.appendChild(s);"
          end
          submit_function << "f.submit();"
        end
      
    end
  end
end