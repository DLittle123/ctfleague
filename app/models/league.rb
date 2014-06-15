class League < ActiveRecord::Base
  belongs_to :commissioner, :class_name => :User, :foreign_key => 'user_id'
  has_many :teams
  has_many :seasons
  has_many :drafts
  has_many :memberships
  has_many :users, through: :memberships
  has_many :teams, through: :league_teams

  validates_presence_of :commissioner
  validates_uniqueness_of :name

  scope :active, -> { where(active: true) }

  after_create :generate_league_key

  private

  def generate_league_key
    league_key = ('a'..'z').to_a.shuffle[0,8].join
    self.league_key = league_key
    self.save
  end
end
