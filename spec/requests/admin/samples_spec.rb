# frozen_string_literal: true

require 'rails_helper'

describe 'Samples' do
  shared_examples 'allows read access' do
    describe '#GET samples index page' do
      it 'returns 200' do
        create(:sample)
        get admin_samples_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET samples show page' do
      it 'returns 200' do
        sample = create(:sample)
        get admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'allows read access for #index' do
    describe '#GET samples index page' do
      it 'returns 200' do
        create(:sample)
        get admin_samples_path

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'allows #show access for own samples' do
    describe '#GET samples show page' do
      it 'returns 200' do
        processor = Researcher.with_role(:sample_processor).first
        sample = FactoryBot.create(:sample, processor: processor)
        get admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'allows full write access' do
    describe '#POST' do
      it 'creates a new sample' do
        attributes = { bar_code: '123', project_id: create(:project).id }
        params = { sample: attributes }

        expect { post admin_samples_path, params: params }
          .to change(Sample, :count).by(1)
      end
    end

    describe '#PUT' do
      it 'updates a sample' do
        sample = FactoryBot.create(:sample, bar_code: '123')
        params = { id: sample.id, sample: { bar_code: 'abc' } }
        put admin_sample_path(id: sample.id), params: params
        sample.reload

        expect(sample.bar_code).to eq('abc')
      end
    end

    describe '#DELETE' do
      it 'deletes a sample' do
        sample = FactoryBot.create(:sample)

        expect { delete admin_sample_path(id: sample.id) }
          .to change(Sample, :count).by(-1)
      end
    end

    describe '#GET samples new page' do
      it 'redirects to admin root' do
        get new_admin_sample_path

        expect(response.status).to eq(200)
      end
    end

    describe '#GET samples edit page' do
      it 'redirects to admin root' do
        sample = create(:sample, bar_code: '123')
        get edit_admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'denies create access' do
    describe '#POST' do
      it 'does not create a new sample' do
        attributes = { bar_code: '123', project_id: create(:project).id }
        params = { sample: attributes }

        expect { post admin_samples_path, params: params }
          .to change(Sample, :count).by(0)
      end
    end

    describe '#GET samples new page' do
      it 'redirects to admin root' do
        get new_admin_sample_path

        expect(response).to redirect_to admin_samples_path
      end
    end
  end

  shared_examples 'allows edit access' do
    describe '#PUT' do
      it 'updates a sample' do
        sample = FactoryBot.create(:sample, bar_code: '123')
        params = { id: sample.id, sample: { bar_code: 'abc' } }
        put admin_sample_path(id: sample.id), params: params
        sample.reload

        expect(sample.bar_code).to eq('abc')
      end
    end

    describe '#GET samples edit page' do
      it 'redirects to admin root' do
        sample = create(:sample, bar_code: '123')
        get edit_admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  shared_examples 'denies delete access' do
    describe '#DELETE' do
      it 'does not delete a sample' do
        sample = FactoryBot.create(:sample)

        expect { delete admin_sample_path(id: sample.id) }
          .to change(Sample, :count).by(0)
      end
    end
  end

  shared_examples 'denies delete access for own samples' do
    describe '#DELETE' do
      it 'does not delete a sample' do
        processor = Researcher.with_role(:sample_processor).first
        sample = FactoryBot.create(:sample, processor: processor)

        expect { delete admin_sample_path(id: sample.id) }
          .to change(Sample, :count).by(0)
      end
    end
  end

  shared_examples 'allows edit access for own samples' do
    describe '#PUT' do
      it 'updates a sample' do
        processor = Researcher.with_role(:sample_processor).first
        sample = FactoryBot.create(:sample, bar_code: '123',
                                            processor: processor)
        params = { id: sample.id, sample: { bar_code: 'abc' } }
        put admin_sample_path(id: sample.id), params: params
        sample.reload

        expect(sample.bar_code).to eq('abc')
      end
    end

    describe '#GET samples edit page' do
      it 'returns 200' do
        processor = Researcher.with_role(:sample_processor).first
        sample = FactoryBot.create(:sample, bar_code: '123',
                                            processor: processor)
        get edit_admin_sample_path(id: sample.id)

        expect(response.status).to eq(200)
      end
    end
  end

  describe 'when researcher is a director' do
    before { login_director }
    include_examples 'allows read access'
    include_examples 'allows full write access'
  end

  describe 'when researcher is a lab_manager' do
    before { login_lab_manager }
    include_examples 'allows read access'
    include_examples 'denies create access'
    include_examples 'allows edit access'
    include_examples 'denies delete access'
  end

  describe 'when researcher is a sample_processor' do
    before { login_sample_processor }
    include_examples 'allows read access for #index'
    include_examples 'allows #show access for own samples'
    include_examples 'denies create access'
    include_examples 'allows edit access for own samples'
    include_examples 'denies delete access for own samples'
  end
end