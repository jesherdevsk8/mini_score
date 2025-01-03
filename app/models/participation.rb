# frozen_string_literal: true

class Participation < ApplicationRecord
  belongs_to :player
  belongs_to :match
  belongs_to :team

  enum :match_result, victory: 'vitoria', draw: 'empate', defeat: 'derrota', _prefix: true

  validates :goals, numericality: { greater_than_or_equal_to: 0 }
  validates :match_result, :player, :match, :team, presence: true

  scope :by_year, ->(year) {
    where(created_at: Time.new(year).beginning_of_year..Time.new(year).end_of_year) if year.present?
  }

  scope :by_date, ->(date) {
    return order(created_at: :desc) unless date.present?

    joins(:match).where(matches: { date: date })
  }

  def self.results
    match_results.except('_prefix').invert.map { |k, v| [ k.humanize, v ] }
  end
end
