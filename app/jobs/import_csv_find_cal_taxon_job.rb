# frozen_string_literal: true

class ImportCsvFindCalTaxonJob < ApplicationJob
  include ImportCsv::EdnaResultsTaxa

  queue_as :default

  def perform(taxonomy_string)
    find_cal_taxon(taxonomy_string)
  end
end
