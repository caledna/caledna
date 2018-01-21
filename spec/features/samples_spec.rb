# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'samples index page' do
    let(:project) { create(:project) }
    let!(:sample1) do
      create(:sample, bar_code: 'sample 1', project: project,
                      status_cd: :approved)
    end
    let!(:sample2) do
      create(:sample, bar_code: 'sample 2', project: project,
                      status_cd: :analyzed)
    end
    let!(:sample3) do
      create(:sample, bar_code: 'sample 3', project: project,
                      status_cd: :results_completed)
    end
    let!(:sample4) do
      create(:sample, bar_code: 'sample 4', status_cd: :analyzed)
    end
    let!(:sample5) do
      create(:sample, bar_code: 'sample 5', status_cd: :results_completed)
    end

    it 'renders all samples when no query string' do
      visit samples_path
      expect(page).to have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to have_content 'sample 4'
      expect(page).to have_content 'sample 5'
    end

    it 'renders samples for a project when project_id is in query string' do
      visit samples_path(project_id: project.id)

      expect(page).to have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders analyzed samples when status=analyzed is in query string' do
      visit samples_path(status: :analyzed)

      expect(page).to_not have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to_not have_content 'sample 3'
      expect(page).to have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders samples when results when status=results_completed is '\
       'in query string' do
      visit samples_path(status: :results_completed)

      expect(page).to_not have_content 'sample 1'
      expect(page).to_not have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to have_content 'sample 5'
    end

    it 'renders analyzed samples for a project when period_id and '\
       'status=analyzed are in query string' do
      visit samples_path(status: :analyzed, project_id: project.id)

      expect(page).to_not have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to_not have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders analyzed samples for a project when period_id and '\
       'status=results_completed are in query string' do
      visit samples_path(status: :results_completed, project_id: project.id)

      expect(page).to_not have_content 'sample 1'
      expect(page).to_not have_content 'sample 2'
      expect(page).to have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end
  end
end