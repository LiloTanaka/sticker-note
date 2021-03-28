ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Note < ActiveRecord::Base
    has_many :stickers
end

class Sticker < ActiveRecord::Base
    belongs_to :note
end