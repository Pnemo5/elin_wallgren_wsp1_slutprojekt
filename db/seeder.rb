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
                cover TEXT)')

    db.execute('CREATE TABLE genres (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                description TEXT)')

    db.execute('CREATE TABLE books_genres (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                book_id INTEGER,
                genre_id INTEGER)')
  end

  def self.populate_tables
    db.execute('INSERT INTO books (title, author, pages, rating, date, review, cover) VALUES ("The Song of Achilles", "Madeline Miller", 408, 5, "januari", "SMÄRTA", "URL")')
    
    db.execute('INSERT INTO genres (name, description) VALUES ("Romantik", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Deckare", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Fantasy", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Sci-fi", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Young adult", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Historisk fiktion", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Biografi", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Manga", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Serietidning", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Grafisk bok", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Barnbok", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Feel-good", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Skräck", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Spänning", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Samtida skönlitteratur", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Äventyr", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Matlagning", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Allegori", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Roman", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Klassiker", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Komedi", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Coming-of-age", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Feministisk", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Dystopi", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Postapokalyptisk", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("HBTQI+", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Mysterie", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Politisk", "")')
    db.execute('INSERT INTO genres (name, description) VALUES ("Arbetarlitteratur", "")')

    db.execute('INSERT INTO books_genres (book_id, genre_id) VALUES (1, 3)')
    db.execute('INSERT INTO books_genres (book_id, genre_id) VALUES (2, 3)')

    
  end

  private

  def self.db
    @db ||= begin
      db = SQLite3::Database.new('db/books.sqlite.db')
      db.results_as_hash = true
      db
    end
  end

  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

end

Seeder.seed!