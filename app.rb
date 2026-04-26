require 'debug'
require "awesome_print"
require 'securerandom'
require 'bcrypt'

require_relative 'models/book'
require_relative 'models/genre'
require_relative 'models/user'
require_relative 'models/login_attempt'

# Huvudklass för webbapplikationen
# Hanterar alla routes (HTTP endpoints), sessions och koppling till models
# Följer MVC-princip där databaskallor ligger i models
class App < Sinatra::Base

    setup_development_features(self)

    # Returnerar en singleton-anslutning till databasen
    #
    # @return [SQLite3::Database] databasinstans
    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      @db.execute("PRAGMA foreign_keys = ON")

      return @db
    end

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end

    helpers do

      # Kollar om användaren är inloggad
      # Om man inte är inloggad så redirectas man till login-sidan
      #
      # @return [void]
      def require_login
        redirect '/login' unless session[:user_id]
      end
    
      # Hämtar aktuell inloggad användare från sessionen
      #
      # @return [Hash, nil] användardata eller nil
      def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      end

      # Stoppar åtkomst om användaren inte är admin.
      #
      # @return [void]
      def require_admin
        halt 403, "Hemligt heheheheheh" unless admin?
      end

      # Kontrollerar om nuvarande användare är admin.
      #
      # @return [Boolean] true om admin annars false
      def admin?
        current_user && current_user["admin"] == 1
      end
    end
  
    # Körs innan varje request
    # Sätter @current_user om användaren är inloggad
    #
    # @return [void]
    before do
      if session[:user_id]
        @current_user = User.find(session[:user_id])
      else
        @current_user = nil
      end
    end


    # Omdirigerar till login-sidan
    #
    # @return [void]
    get '/' do
      redirect('/login')
    end

    # Visar alla böcker om för en inloggad användare
    #
    # @return [void]
    get '/books' do
      require_login
      @books = Book.for_user(session[:user_id])
      erb(:"books/index")
    end

    # Visar formuläret för att lägga till en ny bok
    #
    # @return [void]
    get '/books/new' do
      require_login
      @genres = Genre.all_for_user(session[:user_id])
      erb(:"books/new")
    end

    # Skapar en ny bok kopplad till inloggad användare
    #
    # @param params [Hash] datan från formuläret
    # @return [void]
    post '/books' do
      require_login
      params['user_id'] = session[:user_id]
      Book.post(params)
      redirect("/books")
    end

    # Visar en specifik bok och dess kopplade genrer som tillhör den inloggade användaren
    #
    # @return [void]
    get '/books/:id' do
      require_login
    
      @book = Book.find_by_id_and_user_id(params[:id], session[:user_id])
    
      redirect("/login") unless @book

      @genres = Book.specific_genres(params[:id])
    
      erb (:"books/show")
    end

    # Tar bort en bok som tillhör den inloggade användaren
    #
    # @return [void]
    post '/books/:id/delete' do
      require_login
    
      Book.delete(params[:id], session[:user_id])
    
      redirect("/books")
    end

    # Visar formuläret för att redigera en bok
    #
    # @return [void]
    get '/books/:id/edit' do
      require_login
    
      @book = Book.find_by_id_and_user_id(params[:id], session[:user_id])

      redirect("/books") unless @book
    
      @genres = Genre.all_for_user(session[:user_id])
      @book_genres = Book.specific_genres(params[:id])
    
      erb(:"books/edit")
    end

    # Uppdaterar en bok och dess genrer
    #
    # @param params [Hash] formulärdata
    # @return [void]
    post "/books/:id/update" do
      require_login
    
      Book.update(
        params[:id],
        session[:user_id],
        params
      )
    
      redirect("/books")
    end 

    # Visar alla genrer som är globala och specifika för användaren)
    #
    # @return [void]
    get '/genres' do
      require_login
    
      @genres = Genre.all_for_user(session[:user_id])
      
      erb(:"genres/index")
    end
    
    # Visar formulär för att skapa en ny genre
    #
    # @return [void]
    get '/genres/new' do
      require_login
      erb(:"genres/new")
    end

    # Skapar en ny genre kopplad till användaren
    #
    # @param params [Hash] formulärdata
    # @return [void]
    post '/genres' do
      require_login
    
      Genre.post(params, session[:user_id])
    
      redirect("/genres")
    end

    # Visar en specifik genre
    #
    # @return [void]
    get '/genres/:id' do | id |
      require_login
    
      @genres = Genre.find_by_id_and_user(id, session[:user_id])
    
      redirect("/genres") unless @genres
    
      @can_edit = @genres["user_id"].to_i == session[:user_id].to_i
    
      erb(:"genres/show")
    end

    # Visar formulär för att redigera en genre
    #
    # @return [void]
    get '/genres/:id/edit' do | id |
      require_login
    
      @genres = Genre.find_by_id_and_user(id, session[:user_id])
    
      redirect("/genres") unless @genres
    
      redirect("/genres") unless @genres["user_id"] == session[:user_id]
    
      erb(:"genres/edit")
    end

    # Uppdaterar en genre
    #
    # @param params [Hash] formulärdata
    # @return [void]
    post '/genres/:id/update' do |id|
      require_login
    
      genre = Genre.find_by_id_and_user(id, session[:user_id])
      halt 403, "Här kommer du faktiskt inte in" unless genre
    
      Genre.update(id, params)
    
      redirect("/genres")
    end
    
    # Tar bort en genre om användaren har behörighet
    #
    # @return [void]
    post '/genres/:id/delete' do |id|
      require_login
    
      genre = Genre.find_by_id_and_user(id, session[:user_id])
      halt 403, "Stopp" unless genre
    
      Genre.delete(id, session[:user_id])    
      redirect("/genres")
    end

    # Visar alla användare (endast för admin)
    #
    # @return [void]
    get '/users' do
      halt 403, "Du har ej åtkomst till sidan hallå" unless admin?
      @users = User.all();
      erb(:"users/index")
    end

    # Visar formuläret för att registrera en ny användare
    # Blockeras om en användare redan är inloggad
    #
    # @return [void]
    get '/users/new' do
      redirect '/books' if session[:user_id]
      erb(:"users/new")
    end

    # Skapar en ny användare med hashat lösenord
    #
    # @param params [Hash] användardata
    # @return [void]
    post '/users/new' do
      params['password'] = BCrypt::Password.create(params['password'])
      User.post(params);
      erb(:"login")
    end

    # Visar inloggningssidan
    # Redirectar till /books om man redan än inloggad
    #
    # @return [void]
    get '/login' do
      redirect '/books' if session[:user_id]
      erb(:"login")
    end

    # Inloggning av användare
    # Kontrollerar lösenord, blockerar brute-force och skapar en session
    #
    # @return [void]
    post '/login' do
      username = params[:username]
      password = params[:password]
      ip = request.ip
    
      attempts = LoginAttempt.recent_failed_attempts(ip)
    
      if attempts >= 5
        halt 429, "Försök inte hacka sidan :( Vänta 5 min."
      end
    
      user = User.find_by_username(username)
    
      success = false
    
      if user && BCrypt::Password.new(user["password"]) == password
        session[:user_id] = user["id"]
        success = true
      end
    
      LoginAttempt.create(username, ip, success)
    
      if success
        redirect '/books'
      else
        status 401
        redirect '/login'
      end
    end

    # Loggar ut användaren och rensar sessionen
    #
    # @return [void]
    post '/logout' do
      ap "Logging out"
      session.clear
      redirect '/login'
    end


end
