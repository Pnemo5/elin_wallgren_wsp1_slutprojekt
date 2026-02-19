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
  end

  def self.create_tables
    db.execute('CREATE TABLE books (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                author TEXT,
                genre TEXT,
                pages INTEGER,
                rating INTEGER,
                date TEXT,
                review TEXT,
                cover TEXT)')
  end

  def self.populate_tables
    db.execute('INSERT INTO books (title, author, genre, pages, rating, date, review, cover) VALUES ("The Song of Achilles", "Madeline Miller", "roman", 408, 5, "januari", "SMÄRTA", "URL")')
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