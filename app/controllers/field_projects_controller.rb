# frozen_string_literal: true

class FieldProjectsController < ApplicationController
  def index
    @projects =
      FieldProject
      .published
      .where(where_sql)
      .order(:name)
      .page(params[:page])
  end

  def show
    @project = FieldProject.find(project_id)
  end

  private

  def where_sql
    <<-SQL
    id IN (
      SELECT DISTINCT(field_project_id)
      FROM samples
      WHERE status_cd = 'approved' OR status_cd = 'results_completed'
    )
    SQL
  end

  def project_id
    params[:id]
  end
end
