# frozen_string_literal: true

module Api
  module V1
    class LaRiverController < Api::V1::ApplicationController
      before_action :add_cors_headers

      include PaginatedSamples
      include BatchData
      include AsvTreeFormatter

      def sites
        render json: {
          samples: SampleSerializer.new(all_samples.la_river),
          asvs_count: asvs_count
        }, status: :ok
      end

      def area_diversity
        render json: project_service.area_diversity_data, status: :ok
      end

      def pa_area_diversity
        render json: project_service.pa_area_diversity_data, status: :ok
      end

      def detection_frequency
        render json: project_service.detection_frequency, status: :ok
      end

      private

      def project_service
        ResearchProjectService::LaRiver.new(project, params)
      end

      def project
        @project ||= begin
          ResearchProject.find_by(slug: 'los-angeles-river')
        end
      end

      def query_string
        {}
      end
    end
  end
end
