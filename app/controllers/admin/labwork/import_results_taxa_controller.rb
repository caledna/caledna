# frozen_string_literal: true

module Admin
  module Labwork
    class ImportResultsTaxaController < Admin::ApplicationController
      include ImportCsv::TestResultsTaxa

      def index
        authorize 'Labwork::ImportCsv'.to_sym, :index?
        @projects = ResearchProject.all.collect { |p| [p.name, p.id] }
      end

      def create
        authorize 'Labwork::ImportCsv'.to_sym, :create?
        results = import_csv(file, research_project_id, primer, notes)
        if results.valid?
          flash[:success] = 'Importing taxonomies...'
          redirect_to admin_labwork_import_csv_status_index_path
        else
          handle_error(results)
        end
      end

      private

      def handle_error(results)
        flash[:error] = results.errors
        redirect_to admin_labwork_import_results_taxa_path
      end

      def file
        params[:file]
      end

      def research_project_id
        create_params[:research_project_id]
      end

      def primer
        create_params[:primer]
      end

      def notes
        create_params[:notes]
      end

      def create_params
        params.require(:dna_results).permit(
          :research_project_id,
          :primer,
          :notes
        )
      end
    end
  end
end
