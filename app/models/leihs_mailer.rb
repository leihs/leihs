#    This file is part of leihs.
#
#    leihs is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    leihs is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    leihs is (C) Zurich University of the Arts
#    
#    This file was written by:
#    Magnus Rembold
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
