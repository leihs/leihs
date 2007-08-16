class LeihsMailer < ActionMailer::Base

	# Nutzer hat Zugang beantragt, hiermit bekommt er eine Mail mit einem Link
	# zur Zugangsfreischaltung
  def aktivierung( in_user )
    @subject    = '[leihs] Ihre Zugangsaktivierung'
    @body       = { :user => in_user }
    @recipients = in_user.email
    @from       = 'no-reply@zhdk.ch'
		@sent_on		= Time.now
    @headers    = {}
  end

	# Nutzer hat Reservation getätigt, hiermit bekommt er Mailbenachrichtigungen
	# mit geandertem Zustand (wenn dieser von Herausgebern geändert wird)
  def benachrichtigung( in_reservation )
    @subject    = '[leihs] Ihr Reservationsstatus'
    @body       = { :reservation => in_reservation }
    @recipients = ( in_reservation.user ? in_reservation.user.email : in_reservation.updater.email )
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = Time.now
    @headers    = {}
  end

	# Nutzer hat ausgeliehene Reservation nicht zurückgebracht, hiermit bekommt
	# er eine Mahnung, dass er die Pakete bitte sofort zurückbringt
  def mahnung_ueberfaellig( in_reservation )
    @subject    = '[leihs] Ueberfaellige Rueckgaben'
    @body       = { :reservation => in_reservation }
    @recipients = ( in_reservation.user ? in_reservation.user.email : in_reservation.updater.email )
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = Time.now
    @headers    = {}
  end

	# Nutzer hat offene Reservationen, die überfällig sind, hiermit bekommt
	# er Benachrichtigung, dass er sie abholen oder stornieren soll
  def mahnung_reservation( in_reservation )
    @subject    = '[leihs] Ueberfaellige Rueckgaben'
    @body       = { :reservation => in_reservation }
    @recipients = ( in_reservation.user ? in_reservation.user.email : in_reservation.updater.email )
    @from       = 'no-reply@zhdk.ch'
    @sent_on    = Time.now
    @headers    = {}
  end
end
