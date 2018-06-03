# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  describe 'samples index page' do
    let(:project) { create(:field_data_project) }
    let!(:sample1) do
      create(:sample, barcode: 'sample 1', status_cd: :approved)
    end
    let!(:sample2) do
      create(:sample, barcode: 'sample 2', status_cd: :processing_sample)
    end
    let!(:sample3) do
      create(:sample, barcode: 'sample 3', status_cd: :results_completed)
    end
    let!(:sample4) do
      create(:sample, barcode: 'sample 4', status_cd: :submitted)
    end

    let!(:sample5) do
      create(:sample, barcode: 'sample 5', status_cd: :rejected)
    end

    it 'renders all approved samples when no query string' do
      visit samples_path(view: :list)

      expect(page).to have_content 'sample 1'
      expect(page).to have_content 'sample 2'
      expect(page).to have_content 'sample 3'
    end

    it 'does not render unapproved samples' do
      visit samples_path(view: :list)
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end

    it 'renders one sample when sample_id is in query string' do
      visit samples_path(view: :list, sample_id: sample1.id)

      expect(page).to have_content 'sample 1'
      expect(page).to_not have_content 'sample 2'
      expect(page).to_not have_content 'sample 3'
      expect(page).to_not have_content 'sample 4'
      expect(page).to_not have_content 'sample 5'
    end
  end
end
