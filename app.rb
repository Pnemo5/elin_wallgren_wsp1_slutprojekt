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
      @books = db.execute('SELECT * FROM books')
      p @books
      erb(:"books/index")
    end

    get '/books/new' do
      erb(:"books/new")
    end

    post '/books' do
      p params
      b_title = params["book_title"]
      b_author = params["book_author"]
      b_genre = params["book_genre"]
      b_pages = params["book_pages"]
      b_rating = params["book_rating"]
      b_date = params["book_date"]
      b_review = params["book_review"]
      b_cover = params["book_cover"]

      db.execute("INSERT INTO books (title, author, genre, pages, rating, date, review, cover)
      VALUES(?, ?, ?, ?, ?, ?, ?, ?)", [b_title, b_author, b_genre, b_pages, b_rating, b_date, b_review, b_cover])
      redirect("/books")
    end

    get '/books/:id' do | id |
      @books = db.execute('SELECT * FROM books WHERE id=?', id)[0]
      erb(:"books/show")
    end

end
