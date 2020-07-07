# frozen_string_literal: true

class ResearchProjectsController < ApplicationController
  include CustomPagination
  include CheckWebsite
  include FilterSamples
  layout 'river/application' if CheckWebsite.pour_site?

  def index
    @projects = projects
    @taxa_count = taxa_count
    @families_count = families_count
    @samples_with_results_count = completed_samples_count
  end

  def show
    redirect_show if project&.show_pages?
    @project = project
  end

  private

  # =======================
  # index
  # =======================

  # NOTE: this query provides the samples count per project
  # rubocop:disable Metrics/MethodLength
  def projects_sql
    sql = <<-SQL
    SELECT research_projects.id, research_projects.name,
    research_projects.slug,
    COUNT(*)
    FROM research_projects
    JOIN research_project_sources
      ON research_projects.id = research_project_sources.research_project_id
      AND sourceable_type = 'Sample'
    WHERE research_projects.published = TRUE
    AND sourceable_id IN (SELECT DISTINCT sample_id FROM sample_primers)
    SQL

    if CheckWebsite.pour_site?
      sql += "AND research_projects.id = #{ResearchProject::LA_RIVER.id}"
    end

    sql + <<-SQL
    GROUP BY research_projects.id
    ORDER BY research_projects.name
    LIMIT $1 OFFSET $2;
    SQL
  end
  # rubocop:enable Metrics/MethodLength

  def projects
    @projects ||= begin
      bindings = [[nil, limit], [nil, offset]]
      raw_records = conn.exec_query(projects_sql, 'q', bindings)
      records = raw_records.map { |r| OpenStruct.new(r) }
      add_pagination_methods(records)
      records
    end
  end

  def count_sql
    <<-SQL
    SELECT COUNT(DISTINCT(research_projects.id))
    FROM research_projects
    JOIN research_project_sources
      ON research_projects.id = research_project_sources.research_project_id
    JOIN samples
      ON research_project_sources.sourceable_id = samples.id
    WHERE samples.status_cd = 'results_completed'
    AND latitude IS NOT NULL
    AND longitude IS NOT NULL
    AND sourceable_type = 'Sample';
    SQL
  end

  def families_count
    @families_count ||= begin
      results = conn.exec_query(rank_count('family'))
      results.entries[0]['count']
    end
  end

  def rank_count(rank)
    <<-SQL
    SELECT COUNT(DISTINCT(hierarchy_names ->> '#{rank}'))
    FROM ncbi_nodes
    WHERE taxon_id IN (
      SELECT taxon_id FROM asvs GROUP BY taxon_id
    );
    SQL
  end

  # =======================
  # show
  # =======================

  def redirect_show
    redirect_to research_project_page_url(
      research_project_id: project.slug, id: project.default_page.slug
    )
  end

  def project
    @project ||= ResearchProject.find_by(slug: params[:id])
  end
end
