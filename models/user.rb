class User

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

  # Hämtar alla användare (endast username)
  #
  # @return [Array<Hash>] Lista med användare
  def self.all()
    return db.execute("SELECT username FROM users")
  end

  # Skapar en ny användare
  #
  # @param data [Hash] Formdata (username + password)
  # @return [void]
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

  # Hämtar en användare via ID
  #
  # @param id [Integer] User-ID
  # @return [Hash, nil]
  def self.find(id)
    db.execute("SELECT * FROM users WHERE id = ?", id).first
  end

  # Hämtar en användare via användarnamn
  #
  # @param username [String] användarnamn
  # @return [Hash, nil]
  def self.find_by_username(username)
    db.execute("SELECT * FROM users WHERE username = ?", username).first
  end

end