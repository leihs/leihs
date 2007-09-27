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
class KaufvorgangsController < ApplicationController

	include LoginSystem
	layout 'allgemein'
	before_filter :admin_required

  def index
    redirect_to :controller => 'gegenstands', :action => 'list' 
  end

  def show
    @kaufvorgang = Kaufvorgang.find(params[:id])
    @gegenstand = Gegenstand.find( @kaufvorgang.gegenstand.id )
  end

  def new
		@gegenstand = Gegenstand.find( params[ :id ] )
    @kaufvorgang = Kaufvorgang.new
  end

  def create
  	@gegenstand = Gegenstand.find( params[ :id ] )
    @kaufvorgang = Kaufvorgang.new( params[ :kaufvorgang ] )
    if @kaufvorgang.save
			@gegenstand.kaufvorgang_id = @kaufvorgang.id
			if @gegenstand.save
				flash[ :notice ] = 'Kaufvorgang wurde eingetragen.Gegenstand aktualisiert'
	      redirect_to :controller => 'gegenstands', :action => 'list'
	    else
	    	flash[ :notice ] = 'Kaufvorgang wurde eingetragen.Gegenstand konnte nicht aktualisiert werden.'
    	  render_action 'new'
			end
		else
			flash[ :notice ] = 'Kaufvorgang konnte nicht eingetragen werden.'
			render_action 'new'
    end
  end

	def edit
		show
	end

  def update
    @kaufvorgang = Kaufvorgang.find( params[ :id ] )
    if @kaufvorgang.update_attributes( params[ :kaufvorgang ] )
      flash[ :notice ] = 'Kaufvorgang wurde geaendert.'
      redirect_to :controller => 'gegenstands', :action => 'edit', :id => @kaufvorgang.gegenstand.id
    else
      render_action 'edit'
    end
  end

  def destroy
    @kaufvorgang = Kaufvorgang.find( params[ :id ] )
		@gegenstand_id = @kaufvorgang.gegenstand.id
		@kaufvorgang.destroy
    redirect_to :controller => 'gegenstands', :action => 'edit', :id => @gegenstand_id
  end
end
