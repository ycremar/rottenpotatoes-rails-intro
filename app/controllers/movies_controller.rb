class MoviesController < ApplicationController
  
  def initialize
    super
    @all_ratings = get_ratings
  end
  
  def get_ratings
    ['G','PG','PG-13','R','NC-17'].map{|a| a}
  end
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
  
  def clear
    session.clear
    redirect_to movies_path  
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def get_sort_state
    if session[:sort].nil?
      session[:sort] =  (params[:sort].nil?) ? :unsorted : params[:sort]
    end
    session[:sort]
  end
  
  def get_filter_state
    if params[:commit] == 'Refresh'
      session[:filter] = params[:ratings].keys unless params[:ratings].nil?
    end
    session[:filter] = @all_ratings if session[:filter].nil?
    session[:filter]
  end

  def index
    
    @sort = get_sort_state

    if params[:commit] == 'Refresh' #filter
      if params[:ratings] != nil
        @filter = params[:ratings].keys
      else
        @filter = session[:filter]
      end
    else
      if session[:filter] != nil
        @filter = session[:filter]
      end
    end
    
    if @filter == nil
      @filter = @all_ratings
      puts "Default filter to all ratings"
    end
    
    session[:filter] = @filter
    session[:sort] = @sort

    puts "Filter: #{@filter}"
    puts "Sort by: #{@sort}"

    to_redirect = true if params[:sort] == nil or params[:filter] == nil

    if to_redirect == true
      puts "Redirecting with all params"
      params[:ratings] = @filter
      params[:sort]    = @sort
      redirect_to movies_path(sort: @sort, filter: @filter)
      return
    end
    
    if (@sort != nil) and (@sort != "unsorted")
      @movies = Movie.where("rating IN (?)", @filter).order(@sort)
    else
      puts "Unsorted"
      @movies = Movie.where("rating IN (?)", @filter)
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end