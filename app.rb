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
      @books = db.execute('SELECT books.*, GROUP_CONCAT(genres.name) AS genres
        FROM books
        LEFT JOIN books_genres ON books.id = books_genres.book_id
        LEFT JOIN genres ON genres.id = books_genres.genre_id
        GROUP BY books.id')
      @books_genres = db.execute("SELECT * FROM books_genres")
      p @books
      p @books_genres
      erb(:"books/index")
    end

    get '/books/new' do
      @genres = db.execute("SELECT * FROM genres")
      erb(:"books/new")
    end

    post '/books' do
      p params
      b_title = params["book_title"]
      b_author = params["book_author"]
      b_pages = params["book_pages"]
      b_rating = params["book_rating"]
      b_date = params["book_date"]
      b_review = params["book_review"]
      b_cover = params["book_cover"]

      db.execute("INSERT INTO books (title, author, pages, rating, date, review, cover)
      VALUES(?, ?, ?, ?, ?, ?, ?)", [b_title, b_author, b_pages, b_rating, b_date, b_review, b_cover])

      book_id = db.last_insert_row_id

      if params["genre_ids"]
        params["genre_ids"].each do |genre_id|
          db.execute(
            "INSERT INTO books_genres (book_id, genre_id)
             VALUES (?, ?)",
            [book_id, genre_id]
          )
        end
      end
      redirect("/books")
    end

    get '/books/:id' do | id |
      @books = db.execute('SELECT * FROM books WHERE id=?', id)[0]
      erb(:"books/show_books")
    end

    post '/books/:id/delete' do | id |
      db.execute("DELETE FROM books WHERE id=?", id)
      redirect("/books")
    end

    get '/books/:id/edit' do | id |
      ap id
      @book = db.execute("SELECT * FROM books WHERE id=?", id)[0]
      p @books
      erb(:"books/edit")
    end

    post "/books/:id/update" do | id |
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
      ap params
      redirect("/books")
    end     

end
