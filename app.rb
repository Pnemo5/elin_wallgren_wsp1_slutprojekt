require 'debug'
require "awesome_print"
require 'securerandom'
require 'bcrypt'

require_relative 'models/book'
require_relative 'models/genre'
require_relative 'models/user'
class App < Sinatra::Base

    setup_development_features(self)

    # Funktion för att prata med databasen
    # Exempel på användning: db.execute('SELECT * FROM fruits')
    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    get '/' do
      redirect('/login')
    end

    get '/books' do
      @books = Book.all();
      erb(:"books/index")
    end

    get '/books/new' do
      @genres = Book.new();
      erb(:"books/new")
    end

    post '/books' do
      Book.post(params);
      redirect("/books")
    end

    get '/books/:id' do | id |
      @books = Book.find(id);
      @genres = Book.specific_genres(id);
      erb(:"books/show")
    end

    post '/books/:id/delete' do | id |
      Book.delete(id);
      redirect("/books")
    end

    get '/books/:id/edit' do | id |
      ap id
      @book = Book.edit(id);
      erb(:"books/edit")
    end

    post "/books/:id/update" do | id |
      Book.update(id, params);
      ap params
      redirect("/books")
    end     

    get '/genres' do
      @genres = Genre.all();
      erb(:"genres/index")
    end
    
    get '/genres/new' do
      erb(:"genres/new")
    end

    post '/genres' do
      Genre.post(params);
      redirect("/genres")
    end

    get '/genres/:id' do | id |
      @genres = Genre.find(id)
      erb(:"genres/show")
    end

    get '/genres/:id/edit' do | id |
      ap id
      @genres = Genre.edit(id);
      erb(:"genres/edit")
    end

    post '/genres/:id/update' do | id |
      Genre.update(id, params);
      ap params
      redirect("/genres")
    end    
    
    post '/genres/:id/delete' do | id |
      Genre.delete(id);
      redirect("/genres")
    end

    get '/users' do
      @users = User.all();
      erb(:"users/index")
    end

    get '/users/new' do
      erb(:"users/new")
    end

    post '/users/new' do
      params['password'] = BCrypt::Password.create(params['password'])
      User.post(params);
      erb(:"login")
    end

    get '/login' do
      erb(:"login")
    end

    post '/login' do
      request_username = params[:username]
      request_plain_password = params[:password]

      user = db.execute("SELECT *
            FROM users
            WHERE username = ?",
            request_username).first

      unless user
        ap "/login : Invalid username."
        status 401
        redirect '/acces_denied'
      end

      db_id = user["id"].to_i
      db_password_hashed = user["password"].to_s

      # Create a BCrypt object from the hashed password from db
      bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
      # Check if the plain password matches the hashed password from db
      if bcrypt_db_password == request_plain_password
        ap "/login : Logged in -> redirecting to admin"
        session[:user_id] = db_id
        redirect '/books'
      else
        ap "/login : Invalid password."
        status 401
        redirect '/login'
      end
    end

    post '/logout' do
      ap "Logging out"
      session.clear
      redirect '/books'
    end


end
