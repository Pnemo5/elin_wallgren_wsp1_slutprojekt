class User
  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

  def self.all()
    return db.execute("SELECT username FROM users")
  end


  def self.post(data)
    db.execute(
      "INSERT INTO users (username, password)
       VALUES (?, ?)",
      [
        data["username"],
        data["password"],
      ]
    )
  end
  
end