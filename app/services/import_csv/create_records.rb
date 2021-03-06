# frozen_string_literal: true

module ImportCsv
  module CreateRecords
    include CustomCounter
    include ProcessEdnaResults

    def create_asv(attributes)
      record = Asv.create(attributes)

      return record if record.valid?
      raise ImportError,
            "ASV #{attributes[:sample_id]}: #{record.errors.messages}"
    end

    def first_or_create_sample_primer(attributes)
      record = SamplePrimer.where(attributes).first_or_create

      return record if record.valid?
      sample_id = attributes[:sample_id]
      primer_id = attributes[:primer_id]

      raise ImportError,
            "SamplePrimer #{sample_id} #{primer_id}: #{record.errors.messages}"
    end

    def first_or_create_research_project_source(sourceable_id, type,
                                                research_project_id)
      attributes = {
        sourceable_id: sourceable_id,
        sourceable_type: type,
        research_project_id: research_project_id
      }

      record = ResearchProjectSource.where(attributes).first_or_create

      return if record.valid?
      raise ImportError,
            "ResearchProjectSource #{sourceable_id}: #{record.errors.messages}"
    end

    def create_result_taxon(data)
      ResultTaxon.create(data)
    end

    private

    def convert_header_to_primer(cell)
      return unless cell.include?('_')
      cell.split('_').first
    end
  end
end

class ImportError < StandardError
end
