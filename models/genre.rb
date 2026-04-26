class Genre

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

  # Hämtar alla globala genrer och genrer som tillhör en specifik användare
  #
  # @param user_id [Integer] ID på inloggad användare
  # @return [Array<Hash>] Lista med genrer
  def self.all_for_user(user_id)
    db.execute("SELECT * FROM genres WHERE user_id IS NULL OR user_id = ?",[user_id])
  end

  # Skapar en ny genre
  #
  # @param data [Hash] Formdata från formulär
  # @param user_id [Integer] ID på användaren som skapar genren
  # @return [void]
  def self.post(data, user_id)
    db.execute(
      "INSERT INTO genres (name, description, user_id)
       VALUES (?, ?, ?)",
      [
        data["genre_name"],
        data["genre_description"],
        user_id
      ]
    )
  end

  # Uppdaterar en genre
  #
  # @param id [Integer] Genre-ID
  # @param data [Hash] Formdata
  # @return [void]
  def self.update(id, data)
    db.execute(
      "UPDATE genres
       SET name = ?, description = ?
       WHERE id = ?",
      [
        data["genre_name"],
        data["genre_description"],
        id
      ]
    )
  end

  # Tar bort en genre (om användaren äger den eller den är global)
  #
  # @param id [Integer] Genre-ID
  # @param user_id [Integer] Användar-ID
  # @return [void]
  def self.delete(id, user_id)
    db.execute(
      "DELETE FROM genres WHERE id = ? AND (user_id IS NULL OR user_id = ?)",
      [id, user_id]
    )
  end

  # Hämtar en specifik genre om användaren har rätt att se den
  #
  # @param id [Integer] Genre-ID
  # @param user_id [Integer] Användar-ID
  # @return [Hash, nil]
  def self.find_by_id_and_user(id, user_id)
    db.execute(
      "SELECT * FROM genres WHERE id = ? AND (user_id IS NULL OR user_id = ?)",
      [id, user_id]
    ).first
  end



end