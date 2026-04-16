class Book

  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

  def self.all()
    return db.execute('SELECT books.*, GROUP_CONCAT(genres.name) AS genres
    FROM books
    LEFT JOIN books_genres ON books.id = books_genres.book_id
    LEFT JOIN genres ON genres.id = books_genres.genre_id
    GROUP BY books.id');
  end


  def self.new()
    return db.execute("SELECT * FROM genres");
  end


  def self.post(data)
    db.execute(
      "INSERT INTO books (title, author, pages, rating, date, review, cover)
       VALUES (?, ?, ?, ?, ?, ?, ?)",
      [
        data["book_title"],
        data["book_author"],
        data["book_pages"],
        data["book_rating"],
        data["book_date"],
        data["book_review"],
        data["book_cover"]
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

  def self.find(id)
    return db.execute('SELECT * FROM books WHERE id=?', id)[0];
  end

  def self.specific_genres(id)
    db.execute("
      SELECT genres.name
      FROM genres
      INNER JOIN books_genres
      ON genres.id = books_genres.genre_id
      WHERE books_genres.book_id = ?
      ", id);
  end

  def self.delete(id)
    db.execute("DELETE FROM books WHERE id=?", id);
  end

  def self.edit(id)
    return db.execute("SELECT * FROM books WHERE id=?", id)[0];
  end

  def self.update(id, data)
    db.execute(
    "UPDATE books
     SET title = ?, author = ?, pages = ?, rating = ?, date = ?, review = ?, cover = ?
     WHERE id = ?",
    [
      data["book_title"],
      data["book_author"],
      data["book_pages"],
      data["book_rating"],
      data["book_date"],
      data["book_review"],
      data["book_cover"],
      id
    ]
  )

    # Ta bort gamla genrer
    db.execute("DELETE FROM books_genres WHERE book_id = ?", id)

    # Lägg till nya genrer
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