require 'debug'
require "awesome_print"

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
      redirect('/books')
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

end
