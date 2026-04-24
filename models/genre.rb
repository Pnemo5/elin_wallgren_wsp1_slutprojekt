class Genre

  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

  def self.all()
    return db.execute("SELECT * FROM genres")
  end

  def self.edit(id)
    return db.execute("SELECT * FROM genres WHERE id=?", id)[0];
  end

  def self.find(id)
    return db.execute('SELECT * FROM genres WHERE id=?', id)[0];
  end

  def self.post(data)
    db.execute(
      "INSERT INTO genres (name, description)
       VALUES (?, ?)",
      [
        data["genre_name"],
        data["genre_description"],
      ]
    )
  end

  def self.update(id, data)
    db.execute(
    "UPDATE genre
     SET name = ?, description = ?",
    [
      data["genre_name"],
      data["genre_description"],
      id
    ]
  )
  end

  def self.delete(id)
    db.execute("DELETE FROM genres WHERE id=?", id);
  end





end