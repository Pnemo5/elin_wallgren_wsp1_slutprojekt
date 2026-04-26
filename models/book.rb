class Book

  # Returnerar en singleton-anslutning till databasen.
  #
  # @return [SQLite3::Database] databasinstans
  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

  # Hämtar alla böcker för en specifik användare, inklusive deras genrer.
  #
  # @param user_id [Integer] ID på användaren
  # @return [Array<Hash>] lista med böcker och deras tillhörande genrer
  def self.for_user(user_id)
    return db.execute(
      'SELECT books.*, GROUP_CONCAT(genres.name) AS genres
       FROM books
       LEFT JOIN books_genres ON books.id = books_genres.book_id
       LEFT JOIN genres ON genres.id = books_genres.genre_id
       WHERE books.user_id = ?
       GROUP BY books.id',
      user_id
    )
  end

  # Skapar en ny bok i databasen och kopplar den till valda genrer.
  #
  # @param data [Hash] formulärdata för boken
  # @option data [String] :book_title
  # @option data [String] :book_author
  # @option data [Integer] :book_pages
  # @option data [Integer] :book_rating
  # @option data [String] :book_date
  # @option data [String] :book_review
  # @option data [String] :book_cover
  # @option data [Integer] :user_id
  # @option data [Array<Integer>] :genre_ids valda genrer
  # @return [void]
  def self.post(data)
    db.execute(
      "INSERT INTO books (title, author, pages, rating, date, review, cover, user_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      [
        data["book_title"],
        data["book_author"],
        data["book_pages"],
        data["book_rating"],
        data["book_date"],
        data["book_review"],
        data["book_cover"],
        data["user_id"]
      ]
    )

    book_id = db.last_insert_row_id

    if data["genre_ids"]
      data["genre_ids"].each do |genre_id|
        db.execute(
          "INSERT INTO books_genres (book_id, genre_id)
           VALUES (?, ?)",
          [book_id, genre_id]
        )
      end
    end
  end

  # Hämtar alla genrer kopplade till en specifik bok.
  #
  # @param id [Integer] bokens ID
  # @return [Array<Hash>] lista av genrer
  def self.specific_genres(id)
    db.execute("
      SELECT genres.*
      FROM genres
      INNER JOIN books_genres
      ON genres.id = books_genres.genre_id
      WHERE books_genres.book_id = ?
    ", id)
  end

  # Tar bort en bok som tillhör en specifik användare.
  #
  # @param id [Integer] bokens ID
  # @param user_id [Integer] användarens ID
  # @return [void]
  def self.delete(id, user_id)
    db.execute(
      "DELETE FROM books WHERE id = ? AND user_id = ?",
      [id, user_id]
    )
  end

  # Hämtar en bok baserat på ID och användare.
  #
  # @param id [Integer] bokens ID
  # @param user_id [Integer] användarens ID
  # @return [Hash, nil] bok eller nil om den inte finns
  def self.find_by_id_and_user_id(id, user_id)
    db.execute(
      "SELECT * FROM books WHERE id = ? AND user_id = ?",
      [id, user_id]
    ).first
  end

  # Uppdaterar en bok och dess kopplade genrer.
  #
  # @param id [Integer] bokens ID
  # @param user_id [Integer] användarens ID
  # @param data [Hash] formulärdata
  # @return [void]
  def self.update(id, user_id, data)
    db.execute(
      "UPDATE books
       SET title = ?, author = ?, pages = ?, rating = ?, date = ?, review = ?, cover = ?
       WHERE id = ? AND user_id = ?",
      [
        data["book_title"],
        data["book_author"],
        data["book_pages"],
        data["book_rating"],
        data["book_date"],
        data["book_review"],
        data["book_cover"],
        id,
        user_id
      ]
    )
  
    db.execute("DELETE FROM books_genres WHERE book_id = ?", id)
  
    if data["genre_ids"]
      data["genre_ids"].each do |genre_id|
        db.execute(
          "INSERT INTO books_genres (book_id, genre_id)
          VALUES (?, ?)",
          [id, genre_id]
        )
      end
    end
  end


  
end