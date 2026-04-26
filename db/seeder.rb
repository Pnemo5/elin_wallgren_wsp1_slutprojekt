require 'sqlite3'
require_relative '../config'
require 'bcrypt'
class Seeder

  def self.seed!
    puts "Using db file: #{'db/DB_PATH'}"
    puts "🧹 Dropping old tables..."
    drop_tables
    puts "🧱 Creating tables..."
    create_tables
    puts "🍎 Populating tables..."
    populate_tables
    puts "✅ Done seeding the database!"
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS books')
    db.execute('DROP TABLE IF EXISTS genres')
    db.execute('DROP TABLE IF EXISTS books_genres')
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS login_attempts')


  end

  def self.create_tables
    db.execute('CREATE TABLE books (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                author TEXT,
                pages INTEGER,
                rating INTEGER,
                date TEXT,
                review TEXT,
                cover TEXT,
                user_id INTEGER)')

    db.execute('CREATE TABLE genres (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                description TEXT,
                user_id INTEGER)')

    db.execute('CREATE TABLE books_genres (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                book_id INTEGER,
                genre_id INTEGER,
                FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
                FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE)')

    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                password TEXT,
                admin INTEGER DEFAULT 0)')

    db.execute('CREATE TABLE login_attempts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                ip_address TEXT,
                success INTEGER,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP)');
  end

  def self.populate_tables
    db.execute('INSERT INTO books (title, author, pages, rating, date, review, cover, user_id) VALUES ("The Song of Achilles", "Madeline Miller", 408, 5, "januari", "SMÄRTA", "URL", 1)')
    

    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Romantik", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Deckare", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Fantasy", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Sci-fi", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Young adult", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Historisk fiktion", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Biografi", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Manga", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Serietidning", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Grafisk bok", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Barnbok", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Feel-good", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Skräck", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Spänning", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Samtida skönlitteratur", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Äventyr", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Matlagning", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Allegori", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Roman", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Klassiker", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Komedi", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Coming-of-age", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Feministisk", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Dystopi", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Postapokalyptisk", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("HBTQI+", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Mysterie", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Politisk", "", NULL)')
    db.execute('INSERT INTO genres (name, description, user_id) VALUES ("Arbetarlitteratur", "", NULL)')


    db.execute('INSERT INTO books_genres (book_id, genre_id) VALUES (1, 3)')
    db.execute('INSERT INTO books_genres (book_id, genre_id) VALUES (2, 3)')

    password_hashed = BCrypt::Password.create("123")
    password_hashed2 = BCrypt::Password.create("321")
    db.execute('INSERT INTO users (username, password, admin) VALUES (?, ?, ?)',["Elin", password_hashed, 1])
    db.execute('INSERT INTO users (username, password, admin) VALUES (?, ?, ?)',["Testis Festis", password_hashed2, 0])

    
  end

  private


  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

end

Seeder.seed!