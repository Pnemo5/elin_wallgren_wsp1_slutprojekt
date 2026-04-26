class LoginAttempt

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

   # Räknar antal misslyckade inloggningar från en IP de senaste 5 minuterna
  #
  # @param ip [String] IP-adress
  # @return [Integer] Antal misslyckade försök
  def self.recent_failed_attempts(ip)
    db.execute(
      "SELECT COUNT(*) AS count FROM login_attempts
       WHERE ip_address = ?
       AND success = 0
       AND created_at > DATETIME('now', '-5 minutes')",
      ip
    ).first["count"]
  end

  # Skapar en loggpost för ett inloggningsförsök
  #
  # @param username [String] Användarnamn
  # @param ip [String] IP-adress
  # @param success [Boolean] Om inloggningen lyckades
  # @return [void]
  def self.create(username, ip, success)
    db.execute(
      "INSERT INTO login_attempts (username, ip_address, success)
       VALUES (?, ?, ?)",
      [username, ip, success ? 1 : 0]
    )
  end
end