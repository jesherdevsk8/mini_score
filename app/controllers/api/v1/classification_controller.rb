# frozen_string_literal: true

module Api
  module V1
    class ClassificationController < ApiV1ApplicationController
      before_action :set_team, only: :show

      def show
        team = set_team
        return render json: { error: 'Equipe não encontrada' }, status: :not_found unless team

        year = params[:year].present? ? Date.new(params[:year].to_i).year : Time.current.year
        players = team.get_players(year)
        top_scorers = team.get_top_scorers(year)

        render json: {
          data: players.sort_by { |hash| -hash[:statistics][:performance_percentage] },
          top_scorers: top_scorers
        }
      end

      private

      def set_team
        @set_team ||= Team.find_by_slug(params[:slug])
      end
    end
  end
end
