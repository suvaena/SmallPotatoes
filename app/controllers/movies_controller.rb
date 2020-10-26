class MoviesController < ApplicationController
  def index
      @movies = Movie.all
  end

  def create
      @movie = Movie.new
      @movie.title = params[:title]
      @movie.rating = params[:rating]
      @movie.release_date = params[:release_date]
      @movie.description = params[:description]
      success = @movie.save
          # NOTE:  The movie will now have a valid id in movie.id
      if success == true
          redirect_to "/movies/" + @movie.id.to_s
      else
          flash.now[:message] = "The movie you created was not saved."
      end
  end
    
  def new
  end

  def edit
  end

  def show
      if /\d+/ =~ params[:id]
          begin
              @movie = Movie.find params[:id]
          rescue
              flash[:message] = "Unable to show movie. Id does not exist."
          end
      else
          flash[:message] = 'Unable to show movie. Invalid id.'
      end
  end
    
  def update
  end

  def destroy
  end
end
