class Game < CouchRest::ExtendedDocument
  use_database WORDDITDB
  
  timestamps!
  
  property :current_player_index
  property :status # pending, inprogress, completed
  property :players, :cast_as => ['GamePlayer']
  property :tile_bag, :cast_as => ['GameTile']
  property :moves, :cast_as => ['GameMove']
  property :board, :cast_as => 'GameBoard'
  property :messages, :cast_as => ['GameMessage']
  
  view_by :user_id, {
    :map => "function(doc) {
      if (doc['couchrest-type'] == 'Game' && doc['players']) {
        doc['players'].forEach(function(player) {
          emit(player['user_id'], null);
        });
      }
    }"
  }
  
  view_by :creation_date, {
    :map => "function(doc) {
      if (doc['couchrest-type'] == 'Game') {
        emit(doc['created_at'], null);
      }
    }"
  }
  
  def start!()
    self.players.each do |p|
      p.rack ||= []
      7.times do
        p.rack << self.tile_bag.delete_at(rand(self.tile_bag.length))
      end
    end
    
    self.current_player_index = rand(self.players.length)
    self.status = 'inprogress'
  end
end

class GamePlayer < Hash
  include CouchRest::CastedModel
  
  property :user_id
  property :score
  property :status # invited, playing, declined
  property :rack, :cast_as => ['GameTile']
end

class GameTile < Hash
  include CouchRest::CastedModel
  
  property :letter
  property :points
end

class GameMessage < Hash
  include CouchRest::CastedModel
  
  property :user_id
  property :date, :cast_as => Time
  property :message
end

@entities << Game
