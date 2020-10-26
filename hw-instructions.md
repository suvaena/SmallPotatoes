# Small Potatoes

This assignment is a reworking of the assignment "Hello Rails" by Armando Fox.  It has been modified for MSCI 245 by Mark Smucker, July 2020.  The signficiant differences between the two is that this version is complete (Hello Rails is draft in progress) and this version works with current version of Ruby and Rails.

This assignment was tested using the MSCI-245-S20 stack (v3) on Codio.  It works with [Ruby 2.6.6](https://ruby-doc.org/core-2.6.6/) and [Rails 6.0.3.2](https://guides.rubyonrails.org/).

----

## Overview

In this assignment, we show you how to create a new Rails app.  We'll make a subset of the rottenpotatoes web app that the ESaaS book talks about.  

Parts:

1. Making a model of movies.
2. RESTful routes for movies.
3. A controller and views for movies.

## Part 0 - A new rails app

Your repo should be named rottenpotatoes.

If you do not have a directory named "rottenpotatoes", stop!  Go back to the homework instructions and properly clone your repo.

`cd` into your repo directory: `cd rottenpotatoes`

There isn't anything in your repo right now except the hw instructions, and the .git directory.

Our first step is to use rails to make you a new app and to get it up and running at the "hello world" level.

Run the following command:

```
rails new . --skip-javascript --skip-test --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-action-cable --skip-active-storage --skip-keeps --skip-spring --skip-sprockets --skip-turbolinks --database=postgresql 
```
Before going further, you should add all of this generated content to git, commit it and push it to GitHub for backup:
```
git add --all
git commit -m"ran rails new"
git push
```

The `rails new .` creates your new app in this directory.  This directory is called the **app root** directory for the new app.

Next, we need to finish setting up the database:
```
rails db:create db:migrate
```
You may get a warning about "The dependency tzinfo-data...", and this warning can be safely ignored every time you see it.

Check to see that the server is alive:
```
rails server -b 0.0.0.0
```
and you should see that it says Puma, the webserver, is running on port 3000.  

At the top of your Codio window, you will see a dropdown menu titled "Project Index (static)".  Click the white downward pointing arrow and select "Box URL".  You will be transported to a new browser tab and you should see a message telling you that you need to configure Rails to allow your machine as an allow host to access the site while in development more.

Copy the text that looks like `config.hosts << "yourCodio-hostname-3000.codio.io"` from the window and proceed by 
editing the file `config/environments/development.rb` and add it after "Rails.application.configure do". So, we get:
```ruby
Rails.application.configure do
    config.hosts << "yourCodio-hostName-3000.codio.io"  
    # ... lots of other stuff not shown here. Don't mess it up.
end
```
Alright.  Stop the web server (puma).  (Hit CTRL-C a couple of times.)

Restart the web server. (Go look back up there for how to do this.)

Go to your website in a browser tab (https://yourCodio-hostName-3000.codio.io/) and verify Rails is running.  You should see something that now congratulates you on getting Rails running.

## psql

When we created the databases in Postgresql for our Rails app, it made two databases:

1. rottenpotatoes_development
1. rottenpotatoes_test

We don't ever touch the test database, for it is used by the testing tools.  

Let's look at the development database.

To do this, we use psql, which is the command line interface to Postgresql.  It is similar to MySQL, but not quite as friendly.

To login to our database, we do:
```
psql -d rottenpotatoes_development
```
To see all the commands in psql, we do `\?`.  Try it.  Press the space bar to page through them all.  Press `b` if you want to scroll up.  When you get to the end, press `q`.  The key presses stand for "back" and "quit".  Memorize them.

To list the tables, enter `\d`.  You should see:
```
               List of relations
 Schema |         Name         | Type  | Owner
--------+----------------------+-------+-------
 public | ar_internal_metadata | table | codio
 public | schema_migrations    | table | codio
(2 rows)
```
These are tables used by Rails.  Don't mess them up.

To escape from psql, enter `\q`.

# Part 1. Model making

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.

Let's have a simple entity model for movies: title, rating (G, PG, PG-13, R, etc.), description, and a release date.

Just like we've seen with generating a controller, we can ask Rails to generate a model for us.  When we ask for a model, we use the **singular** form of the entity name by convention (movie, not movies)

To make the model, do:
```
rails generate model Movie title:string rating:string description:text release_date:datetime
```
and you'll see it output:
```
      invoke  active_record
      create    db/migrate/20200707031838_create_movies.rb
      create    app/models/movie.rb
```
You will have a different number in front of your `_create_movies.rb`.  That number is a timestamp.  

What you've done is make a "migration".  This is a ruby script for making changes to the database.  The beauty of this is that all of our work on the database is recorded in scripts that can be replayed to build a system exactly the same way on other machine, for example in our deploy version in the cloud on Heroku.

The migration can be found in `db/migrate/` in the specific file output in your terminal.  Go open that file, and you will see:
```
class CreateMovies < ActiveRecord::Migration[6.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :rating
      t.text :description
      t.datetime :release_date

      t.timestamps
    end
  end
end
```
Who needs stinkin' SQL DDL?  Even though you don't know the syntax above, you should be able to recognize that this is very similar to creating tables in SQL.  We didn't ask for a `t.timestamps` column, but Rails is going to use this to make some columns that it needs.

In addition to the migration, we also got our model created in `app/models/movie.rb`.  If you open that file, you'll see:
```
class Movie < ApplicationRecord
end
```
Which is pretty simple.  The Movie inherits from ApplicationRecord. Read all about [ActiveRecord and ApplicationRecord](https://guides.rubyonrails.org/active_record_basics.html).

While we've made a migration, we haven't used it yet to change the database.  To add the table to the database, do:
```
rails db:migrate
```
which runs all migrations not yet run.  You will see a message saying that `create_table(:movies)` was run.

Let's go and look into the database and see what happened:
```
psql -d rottenpotatoes_development
```
The in psql, type `\d` to see the tables:
```
rottenpotatoes_development=# \d
                List of relations
 Schema |         Name         |   Type   | Owner
--------+----------------------+----------+-------
 public | ar_internal_metadata | table    | codio
 public | movies               | table    | codio
 public | movies_id_seq        | sequence | codio
 public | schema_migrations    | table    | codio
(4 rows)
```
Cool, eh?  We now have a movies table and a movies_id_seq sequence.  In postgresql, sequence are used to maintain a record of unique ids, much like auto_increment in mysql.  Don't mess with movies_id_seq.

To describe the movies table, enter `\d movies`:
```
                                          Table "public.movies"
    Column    |              Type              | Collation | Nullable |              Default
--------------+--------------------------------+-----------+----------+------------------------------------
 id           | bigint                         |           | not null | nextval('movies_id_seq'::regclass)
 title        | character varying              |           |          |
 rating       | character varying              |           |          |
 description  | text                           |           |          |
 release_date | timestamp without time zone    |           |          |
 created_at   | timestamp(6) without time zone |           | not null |
 updated_at   | timestamp(6) without time zone |           | not null |
Indexes:
    "movies_pkey" PRIMARY KEY, btree (id)
```
We see that our Movie model (singular Movie) produces an entities table movies (plural).  This is a Rails convention, and it is really nice.  The Movie model will represent a row in the table, i.e. a single movie.  The table, is a collection of entities, and thus it is named `movies`.   You can also see how Rails by default gives each entity a unique id name `id`.  There are time extra columns in here that Rails needs: created_at and updated_at.  We don't ever directly manipulate those columns.  Also, we can see that Rail went ahead and put an index on our primary key (the `id` attribute).

Press `q` to exit the display of the table.

Enter `\q` to exit psql.

## Seed the DB

It it handy for development to get some data in the database before proceeding.

We can do this by creating a ruby script that adds movies to the database using the Movie model.

The Movie model, is a class that inherits all the functionality of a `ApplicationRecord` class.  This means that it has a `create` method that we can use to create new movies in the database.  https://guides.rubyonrails.org/active_record_basics.html

In `db/seeds.db` place this code:

```ruby
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
Movie.create(title: 'Aladdin', rating: 'G', release_date: '25-Nov-1992' )
Movie.create(title: 'When Harry Met Sally', rating: 'R', release_date: '21-Jul-1989' )
Movie.create(title: 'The Help', rating: 'PG-13', release_date: '10-Aug-2011' )
Movie.create(title: 'Raiders of the Lost Ark', rating: 'PG', release_date: '12-Jun-1981' )
```
Save the file and then back in the terminal, do:
```
rails db:seed
```
to run the code.

Let's go look in psql and see that this worked:
```
psql -d rottenpotatoes_development
```
Then we can run sql code directly from the prompt:
```
rottenpotatoes_development=# select id,title,rating,description,release_date from movies ;
 id |          title          | rating | description |    release_date
----+-------------------------+--------+-------------+---------------------
  1 | Aladdin                 | G      |             | 1992-11-25 00:00:00
  2 | When Harry Met Sally    | R      |             | 1989-07-21 00:00:00
  3 | The Help                | PG-13  |             | 2011-08-10 00:00:00
  4 | Raiders of the Lost Ark | PG     |             | 1981-06-12 00:00:00
(4 rows)
```
Yay!  

Type `\q` to exit psql.

You can gain some experience with the Movie model and how ActiveRecords work by using the rails console.  The rails console is just like irb, but it know all about our Rail app automatically.

You can safely play around with the database by running rails console with the option --sandbox.  Any changes you make will be rolled back when you exit the console. Do:
```
rails console --sandbox
```
Then do:
```
Movie.all
```
To ask the Movie model for all of the movies.  Notice how this is turned into SQL for you: `SELECT "movies".* FROM "movies" LIMIT 11`.

To find the movie with an id of 1, do:
```
Movie.find(1)
```
You'll see that the method returns and ActiveRecord::Relation, which, as you know, the SQL command: `SELECT "movies".* FROM "movies" WHERE "movies"."id" = 1 LIMIT 1` is returning a relation.  

To print out all movie titles, do:
```
Movie.find_each { |movie| puts movie.title }
```
To delete the movie with id=1, do:
```
Movie.destroy(1)
```
and then list the movies again to verify it is gone:
```
Movie.find_each { |movie| puts movie.title }
```
Type `quit` to exit the console.

# 2. RESTful routes for movies.

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.

You can see the routes for our app by doing:
```
rails routes
```
As you can see, we are lacking in the routes department.  For our app to do anything, we need routes that a user can go to, which are then handled by our controller (to be made), which then renders our views (also to be made).

Recall that routes are kept in `config/routes`.  Open the file up.

Right now it is pretty sparse:
```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

When we have an entity like Movies, Rails calls them a **resource**.  Rails provide a shortcut for making routes for resources.  After the `do`, and before the `end` in the `routes.rb` file, add:
```
resources :movies
```
Save the file, and then run:
```
rails routes
```
We'll now have lots of routes:
```
    Prefix Verb   URI Pattern                Controller#Action
    movies GET    /movies(.:format)          movies#index
           POST   /movies(.:format)          movies#create
 new_movie GET    /movies/new(.:format)      movies#new
edit_movie GET    /movies/:id/edit(.:format) movies#edit
     movie GET    /movies/:id(.:format)      movies#show
           PATCH  /movies/:id(.:format)      movies#update
           PUT    /movies/:id(.:format)      movies#update
           DELETE /movies/:id(.:format)      movies#destroy
```
These are all important.  The GET /movies route is handled by the movies controller's index action.  It is considered the "default" handler, in that it is run when a user requests /movies.  Usually, we have the index provide an overview of the resource, and often provide a list of the items.  For us, that would be a list of the movies in the database.

New to you will be the routes that include an ":id".  For example GET movies/1 will be a request to show the movie with id=1.  

Okay, we have the routes, and we now need a controller and some views.

# 3. A controller and views for movies.

We can ask Rails to make us a controller with the actions we need.  For a resource controller, we also use the plural form of the resource.  Do:
```
rails generate controller movies index create new edit show update destroy 
```
This gives us lots of good stuff:
```
     create  app/controllers/movies_controller.rb
       route  get 'movies/index'
get 'movies/create'
get 'movies/new'
get 'movies/edit'
get 'movies/show'
get 'movies/update'
get 'movies/destroy'
      invoke  erb
      create    app/views/movies
      create    app/views/movies/index.html.erb
      create    app/views/movies/create.html.erb
      create    app/views/movies/new.html.erb
      create    app/views/movies/edit.html.erb
      create    app/views/movies/show.html.erb
      create    app/views/movies/update.html.erb
      create    app/views/movies/destroy.html.erb
      invoke  helper
      create    app/helpers/movies_helper.rb
      invoke  assets
      invoke    css
      create      app/assets/stylesheets/movies.css
```      
Unfortunately, this has generated routes, that we don't need.  Edit `config/routes.rb` and delete the new routes and leave the `resources :movies` directive.

Let's go to our website and see if we've messed it all up.  (If your server isn't running: `rails server -b 0.0.0.0`)

Request `/movies` and you'll see that we get served up the index view.  Cool.  

Try `/movies/1`.  That gives us the show view.  Why didn't it give us the update or destroy views?  Because we made a GET request, and a GET to `movies/1` is routed to movies#show.

Try `movies/1/edit`.  Try `movies/new`.  

Okay, let's work on our controller.  Open up `app/controllers/movies_controller.rb`.

We said that the index view should produce a list of movies.  Remember that the controller mediate between the model and the view.  So, in the index action handler, we should ask the Movie model for all of the entries and put them in a variable for the view to use:
```ruby
  def index
      @movies = Movie.all
  end
```
Remember that the default view to render at the end of an action is the view with the same name as the action.  So, open up `app/views/movies/index.html.erb` and change it to loop through the movies and display their titles:
```html
<h1>Movies</h1>
<ul>
<% @movies.each do |movie| %>
<li><%= movie.title %></li>
<% end %>
</ul>
```
The view has access to the `@movies` variable we made in the controller.  Then we use a simple loop intermixed with simple html to make our list.

Go to /movies on the website and see that it works.

For the 'show' action, recall that the route will be /movies/id where id is a number.  Rails will grab the number and put it in the params hash with the key `:id`.  Let's see if this is true.

In the controller, put the following in the show action handler:
```
  def show
      debugger
  end
```
Now, you should still have a terminal with the puma webserver running.  After you go to /movies/42 in the browser, go back to that terminal, and you should see:
```
Processing by MoviesController#show as HTML
  Parameters: {"id"=>"42"}
Return value is: nil

[12, 21] in /home/codio/workspace/rottenpotatoes/app/controllers/movies_controller.rb
   12:   def edit
   13:   end
   14:
   15:   def show
   16:       debugger
=> 17:   end
   18:
   19:   def update
   20:   end
   21:
(byebug)
```
and we've been dropped into byebug!  To see what is in `params`, type `params` at the byebug prompt:
```
(byebug) params
<ActionController::Parameters {"controller"=>"movies", "action"=>"show", "id"=>"42"} perm
itted: false>
```
So, we see that it knows the controller is movies, and the action is show, and id has been set to 42.  Try typing `params[:id]` and `params["id"]
```
(byebug) params[:id]
"42"
(byebug) params["id"]
"42"
```
These ruby symbols, e.g. :id, are just immutable strings.  So, :id and "id" work the same as a key for the params hash.  Ruby convention is to use the symbols, e.g. `:id`.

Now, type `continue` to let the server finish processing the request.

Being able to debug in this fashion is super powerful.  

Okay, back to the show action and show view.  In the controller, let's get the movie requested:
```ruby
def show
      @movie = Movie.find params[:id] 
  end
```
and in the view (app/views/movies/show.html.erb), we'll show this movie:
```html
<table>
    <tr><td>Title:</td><td><%= @movie.title %></td></tr>
    <tr><td>Rating:</td><td><%= @movie.rating %></td></tr>
    <tr><td>Description:</td><td><%= @movie.description %></td></tr>
    <tr><td>Release Date:</td><td><%= @movie.release_date %></td></tr>
</table>
```
Try it out by going to /movies/1 , /movies/2, etc. in your browser.

# Adding features

If you haven't done it recently, now is a good time to commit your repo and push to GitHub.  This gives you a backup in case of disaster.

Before you are done, we need you to add some further functionality to the app.

## A better index view

1. Modify the index view to also show the movie's year of release in parentheses.  Do not show the full release_date.  For example: Alladin (1992).

1. Modify the index view to provide a link to show each indvidual movie's detailed information via the show route.  

1. Provide a link at the bottom of the page to the 'new' movie route.  The link should read 'Add New Movie'.

## The show action handler

The `show` action handler blindly assume that the id passed in is a valid id.  First, it might not even be a number, and second, we might not have that id in the database.

1. Modify the controller so that the `show` action makes sure the id is a number.  If id is not a number, you should display on the show view a message "Unable to show movie. Invalid id."  

1. Using the [information available about the find method](https://guides.rubyonrails.org/active_record_querying.html#retrieving-a-single-object), if an id does not exist in the databse, have the show view display a message "Unable to show movie.  Id does not exist."

## Adding new movies

Modify the 'new' and 'create' action handlers in the controller and their views to allow a user to enter new movie information on the 'new' view and submit it to the 'create' action, which if successful, sends the user to the show page for that new movie.

To create a new Movie, use `Movie.new` which will return a Movie object that you can store the title, rating, etc. in.  To save the object to the database, call the `save` method, which will return true on success and nil on failure.  For example:
```
@movie = Movie.new
@movie.title = "The Ice Storm"
@movie.rating = "R"
@movie.release_date = "27-Sep-1997"
@movie.description = "Director Ang Lee's best movie.  A must see."
success = movie.save
# NOTE:  The movie will now have a valid id in movie.id 
```
Because our database and Model currently have no restrictions on the data we save, all saves should succeed, and you do not need to handle failure.  In a proper setup, if the save was not successful, we would send the user back to the 'new' view and displays a message "Error: Unable to add new movie.  Please try again." above the form for adding a new movie, or something similar to that.

# Submit Your Work

+ Commit your repo and push to GitHub.

+ Create a Heroku app named small-potatoes-watiamname, where watiamname is your WatIAM user name, and deploy your new game to that app.

+ Because we're using a database, we must also setup the database on Heroku:
```
heroku run rails db:migrate
```
Please also load the seed database:
```
heroku run rails db:seed
```

+ Edit the README.md file to be:

```
# Small Potatoes

Author: Your Name

Heroku URL of deployed web app: http://replace-with-your-heroku-app-hostname/

Notes: Any notes to TA or instructor or notes for yourself.
```
Put your name and Heroku URL into the `README.md` file.  

+ Commit your repo and push to GitHub.

+ Verify that when viewing the Readme in GitHub, that it shows your full name and you can click on the Heroku URL and play your game.

Please note that you will not be able to mark your work as completed in Codio. You submit your work by committing it and pushing it to GitHub and Heroku. **The time of your last commit in GitHub will be used as the time of submission.**

