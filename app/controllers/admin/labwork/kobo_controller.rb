# frozen_string_literal: true

module Admin
  module Labwork
    class KoboController < Admin::ApplicationController
      include KoboApi::Process

      def import_kobo
        authorize 'Labwork::Kobo'.to_sym, :import?

        @projects = ::FieldProject.published.where.not(kobo_id: nil)
                                  .order('last_import_date DESC')
      end

      def import_projects
        authorize 'Labwork::Kobo'.to_sym, :import?

        hash_data = ::KoboApi::Connect.projects.parsed_response
        results = import_kobo_projects(hash_data)

        flash[:error] = 'Could not save data from Kobo API.' unless results
        redirect_to action: 'import_kobo'
      rescue SocketError
        flash[:error] = 'Could not get new data from Kobo API.'
        redirect_to action: 'import_kobo'
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def import_samples
        authorize 'Labwork::Kobo'.to_sym, :import?

        hash_data = ::KoboApi::Connect.project(project.kobo_id).parsed_response
        if hash_data.class == Hash && hash_data['detail'] == 'Not found.'
          flash[:error] = 'Field Project not found in Kobo'
        else
          results_count =
            import_kobo_samples(project.id, project.kobo_id, hash_data)

          flash[:success] = "Importing #{results_count} samples"
        end
        redirect_to action: 'import_kobo'
      rescue SocketError
        flash[:error] = 'Could not get new data from Kobo API.'
        redirect_to action: 'import_kobo'
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      private

      def project
        @project = FieldProject.find(params[:id])
      end
    end
  end
end
