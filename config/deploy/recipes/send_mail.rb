# encoding: utf-8

task :send_mail do
  run "echo 'Deploy von Tag #{branch} durchgefuehrt.' | mail -s '[leihs] Deploy von Tag #{branch} auf produktion durchgefuehrt' nadja.weisskopf@zhdk.ch ramon.cahenzli@zhdk.ch franco.sellitto@zhdk.ch matus.kmit@zhdk.ch"
end
