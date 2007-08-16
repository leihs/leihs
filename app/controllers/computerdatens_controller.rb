class ComputerdatensController < ApplicationController
	
	include LoginSystem
	before_filter :admin_required
	
	layout 'allgemein'
	
	def index
		list
		render_action 'list'
	end

	def list
		@computerdaten_pages, @computerdatens = paginate :computerdaten, :per_page => 10
#		@computerdatens = PaketComp::Computerdaten.find( :all )
	end

	def show
		@computerdaten = Computerdaten.find( params[ :id ] )
		@gegenstand = Gegenstand.find( @computerdaten.gegenstand_id )
	end

	def new
		@gegenstand = Gegenstand.find( params[ :id ] )
		@computerdaten = Computerdaten.new
	end

	def create
	 	@gegenstand = Gegenstand.find( params[ :id ] )
		@computerdaten = Computerdaten.new( params[ :computerdaten ] )
		@computerdaten.gegenstand_id = @gegenstand.id
		if @computerdaten.save
			flash[ :notice ] = 'Computerdaten wurden eingetragen.'
			redirect_to :controller => 'gegenstands', :action => 'edit', :id => @gegenstand.id
		else
		  flash[ :notice ] = 'Computerdaten konnten nicht eingetragen werden.'
			render_action 'new'
		end
	end

	def edit
		show
	end

	def update
		@computerdaten = Computerdaten.find( params[ :id ] )
		if @computerdaten.update_attributes( params[ :computerdaten ] )
			flash[ :notice ] = 'Computerdaten wurden geaendert.'
			redirect_to :action => 'edit', :id => @computerdaten.id
		else
			render_action 'edit'
		end
	end

	def destroy
		Computerdaten.find( params[ :id ] ).destroy
		redirect_to :controller => 'gegenstands', :action => 'edit', :id => @kaufvorgang.gegenstand.id
	end
end
