# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :player
  belongs_to :match
  belongs_to :team

  enum :match_result, victory: 'vitoria', draw: 'empate', defeat: 'derrota', _prefix: true

  validates :goals, numericality: { greater_than_or_equal_to: 0 }
  validates :match_result, :player, :match, :team, presence: true

  after_create :add_goals_conceded

  scope :as_goalkeeper, -> { where.not(non_goalkeeper_mode: true) }

  scope :by_year, ->(year) {
    where(created_at: Time.new(year).beginning_of_year..Time.new(year).end_of_year) if year.present?
  }

  scope :by_date, ->(date) {
    return order(created_at: :desc) unless date.present?

    joins(:match).where(matches: { date: date })
  }

  scope :by_slug, ->(slug) {
    joins(:player).where('players.slug LIKE ? OR players.name LIKE ?', "%#{slug}%", "%#{slug}%")
  }

  def self.results
    match_results.except('_prefix').invert.map { |k, v| [ k.humanize, v ] }
  end

  def add_goals_conceded
    return unless player.goalkeeper? && !non_goalkeeper_mode && match.score.present?

    scores = match.score.split('x').map(&:to_i)

    goals = case
    when victory? then scores.min
    when draw? then scores[0]
    else scores.max
    end

    match_year = match.date.year.to_s
    player.goals_conceded[match_year] ||= 0
    player.goals_conceded[match_year] += goals
    player.update_column(:goals_conceded, player.goals_conceded)
  end
end
