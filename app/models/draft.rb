class Draft < ActiveRecord::Base
  belongs_to :league
  has_many :available_tokens
  has_many :tokens, through: :available_tokens
  has_many :snake_positions
  has_many :users, through: :snake_positions

  def generate_soldiers
    @league = League.find(self.league_id)

    number_of_tokens = 4
    number_of_tokens = 8 if self.season == 1

    @league.memberships.length.times do
      number_of_tokens.times do
        token = Token.new
        unit = Unit.new
        soldier = Soldier.new
        soldier.set_starting_attributes
        unit.soldiers << soldier
        token.units << unit
        self.tokens << token
      end
    end
  end

  def generate_draft_order
    @league = League.find(self.league_id)
    @members = @league.users.shuffle

    position = 1
    @members.each do |member|
      self.snake_positions.create(:user => member, :position => position)
      position = position +1
    end

    self.current_position = 1
    self.save
  end

  def send_draft_end_emails
    DraftMailer.draft_end_email(self)
  end

  def send_draft_beginning_emails
    DraftMailer.draft_beginning_email(self)
  end

  def send_next_turn_email
    DraftMailer.draft_turn_email(self)
  end

  def increment_current_position
    if self.draft_reversed
      if self.current_position > 1
        self.current_position = self.current_position - 1
      else
        self.draft_reversed = false
      end
    else
      if self.current_position == self.snake_positions.length
        self.draft_reversed = true
      else
        self.current_position = self.current_position + 1
      end
    end
    self.save
  end

  def get_recent_picks
    @recent_picks = Array.new
    if self.league.get_all_soldiers != []
      self.league.get_all_soldiers.sort!{|a,b|a.updated_at <=> b.updated_at}.each do |soldier|
        if soldier.age == 18
          @recent_picks << soldier
        end
      end
    end
    @number_to_return = self.league.teams.length*2
    @recent_picks.reverse.slice(0..@number_to_return-1)
  end

end
