# frozen_string_literal: true

module ProcessEdnaResults
  def invalid_taxon?(taxonomy_string)
    return true if taxonomy_string == 'NA'
    return true if taxonomy_string.split(';').blank?
    return true if taxonomy_string.split(';', -1).uniq.sort == ['', 'NA']

    parts_count = taxonomy_string.split(';', -1).count
    return true if parts_count < 6
    return true if parts_count > 7
    false
  end

  # rubocop:disable Metrics/MethodLength
  def format_cal_taxon_data_from_string(taxonomy_string)
    rank = get_taxon_rank(taxonomy_string)
    hierarchy = get_hierarchy(taxonomy_string)

    raise TaxaError, 'rank not found' if rank.blank?
    raise TaxaError, 'hierarchy not found' if hierarchy.blank?

    taxa = find_taxa_by_hierarchy(hierarchy, rank).to_a
    taxon_id = taxa&.size == 1 ? taxa.first.taxon_id : nil

    {
      taxon_id: taxon_id,
      taxon_rank: rank,
      hierarchy: hierarchy,
      original_taxonomy_string: taxonomy_string,
      clean_taxonomy_string: remove_na(taxonomy_string)
    }
  end
  # rubocop:enable Metrics/MethodLength

  def find_taxa_by_hierarchy(hierarchy, target_rank)
    clauses = []
    ranks = %i[superkingdom kingdom phylum class order family genus species]
    ranks.each do |rank|
      next if hierarchy[rank].blank?
      clauses << '"' + rank.to_s + '": "' +
                 hierarchy[rank].gsub("'", "''") + '"'
    end
    sql = "rank = '#{target_rank}' AND  hierarchy_names @> '{"
    sql += clauses.join(', ')
    sql += "}'"

    NcbiNode.where(sql)
  end

  def find_cal_taxon_from_string(string)
    clean_string = remove_na(string)
    rank = if phylum_taxonomy_string?(clean_string)
             get_taxon_rank_phylum(clean_string)
           else
             get_taxon_rank_superkingdom(clean_string)
           end

    CalTaxon.where(clean_taxonomy_string: clean_string)
            .where(taxon_rank: rank).first
  end

  def phylum_taxonomy_string?(string)
    parts = string.split(';', -1)
    if parts.length == 6
      true
    elsif parts.length == 7
      false
    else
      raise TaxaError, "#{string}: invalid taxonomy string"
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_taxon_rank_phylum(string)
    return 'unknown' if string == 'NA'
    return 'unknown' if string == ';;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    if taxa[5].present?
      'species'
    elsif taxa[4].present?
      'genus'
    elsif taxa[3].present?
      'family'
    elsif taxa[2].present?
      'order'
    elsif taxa[1].present?
      'class'
    elsif taxa[0].present?
      'phylum'
    else
      'unknown'
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_hierarchy_phylum(string)
    hierarchy = {}
    return hierarchy if string == 'NA'
    return hierarchy if string == ';;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    hierarchy[:species] = taxa[5] if taxa[5].present?
    hierarchy[:genus] = taxa[4] if taxa[4].present?
    hierarchy[:family] = taxa[3] if taxa[3].present?
    hierarchy[:order] = taxa[2] if taxa[2].present?
    hierarchy[:class] = taxa[1] if taxa[1].present?
    hierarchy[:phylum] = taxa[0] if taxa[0].present?
    hierarchy
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_taxon_rank_superkingdom(string)
    return 'unknown' if string == 'NA'
    return 'unknown' if string == ';;;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    if taxa[6].present?
      'species'
    elsif taxa[5].present?
      'genus'
    elsif taxa[4].present?
      'family'
    elsif taxa[3].present?
      'order'
    elsif taxa[2].present?
      'class'
    elsif taxa[1].present?
      'phylum'
    elsif taxa[0].present?
      'superkingdom'
    else
      'unknown'
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_hierarchy_superkingdom(string)
    hierarchy = {}
    return hierarchy if string == 'NA'
    return hierarchy if string == ';;;;;;'

    clean_taxonomy = remove_na(string)
    taxa = clean_taxonomy.split(';', -1)
    hierarchy[:species] = taxa[6] if taxa[6].present?
    hierarchy[:genus] = taxa[5] if taxa[5].present?
    hierarchy[:family] = taxa[4] if taxa[4].present?
    hierarchy[:order] = taxa[3] if taxa[3].present?
    hierarchy[:class] = taxa[2] if taxa[2].present?
    hierarchy[:phylum] = taxa[1] if taxa[1].present?
    hierarchy[:superkingdom] = taxa[0] if taxa[0].present?
    hierarchy
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # NOTE: adds kingdoms to taxonomy string since test results don't include
  # kingdoms
  def get_complete_taxon_string(string)
    rank = get_taxon_rank_phylum(string)
    hierarchy = get_hierarchy_phylum(string, rank)

    kingdom = hierarchy[:kingdom]
    superkingdom = hierarchy[:superkingdom]

    string = kingdom.present? ? "#{kingdom};#{string}" : ";#{string}"
    string = superkingdom.present? ? "#{superkingdom};#{string}" : ";#{string}"
    string
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def find_sample_from_barcode(barcode, status)
    samples = Sample.where(barcode: barcode)

    if samples.length.zero?
      sample = Sample.create(
        barcode: barcode,
        status_cd: status,
        missing_coordinates: true,
        field_project: FieldProject::DEFAULT_PROJECT
      )

      raise TaxaError, "Sample #{barcode} not created" unless sample.valid?

    elsif samples.all?(&:rejected?) || samples.all?(&:duplicate_barcode?)
      raise TaxaError, "Sample #{barcode} was previously rejected"
    elsif samples.length == 1
      sample = samples.take
      sample.update(status_cd: status)
    else
      valid_samples =
        samples.reject { |s| s.duplicate_barcode? || s.rejected? }

      if valid_samples.length > 1
        raise TaxaError, "multiple samples with barcode #{barcode}"
      end

      sample = valid_samples.first
      sample.update(status_cd: status)
    end
    sample
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def convert_raw_barcode(cell)
    sample = cell.split('_').last
    parts = sample.split('.')

    # NOTE: dot notation. X16S_K0078.C2.S59.L001
    if /^(K\d{4})\.([ABC][12])\./.match?(sample)
      kit = parts.first
      location_letter = parts.second.split('').first
      sample_number = parts.second.split('').second
      "#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: K_L_S_. 'X12S_K0124LBS2.S16.L001'
    elsif /^K(\d{1,4})(L[ABC])(S[12])\./.match?(sample)
      match = /^K(\d{1,4})(L[ABC])(S[12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-#{location_letter}-#{sample_number}"

    # NOTE: K_S_L_. 'X12S_K0404S1LA.S1.L001'
    elsif /^K(\d{1,4})(S[12])(L[ABC])\./.match?(sample)
      match = /^K(\d{1,4})(S[12])(L[ABC])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[3]
      sample_number = match[2]
      "K#{kit}-#{location_letter}-#{sample_number}"

    # NOTE: K_S_L_R_. 'X18S_K0403S1LBR1.S16.L001'
    elsif /^K(\d{1,4})(S[12])(L[ABC])(R\d)\./.match?(sample)
      match = /^K(\d{1,4})(S[12])(L[ABC])(R\d)/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[3]
      sample_number = match[2]
      replicate_number = match[4]
      "K#{kit}-#{location_letter}-#{sample_number}-#{replicate_number}"

    # NOTE: K_LS. PITS_K0001A1.S1.L001
    # NOTE: _LS. X16S_11A1.S18.L001
    elsif /^K?\d{1,4}[ABC][12]\./.match?(sample)
      match = /(\d{1,4})([ABC])([12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: K301B1
    # NOTE: X203C1
    # NOTE: 203C1
    elsif /^[KX]?\d{1,4}[ABC][12]$/.match?(sample)
      match = /(\d{1,4})([ABC])([12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: PP301B1
    elsif /^PP\d{1,4}[ABC][12]$/.match?(sample)
      match = /(\d{1,4})([ABC])([12])/.match(parts.first)
      kit = match[1].rjust(4, '0')
      location_letter = match[2]
      sample_number = match[3]
      "K#{kit}-L#{location_letter}-S#{sample_number}"

    # NOTE: K0401.extneg.S135.L001 or X16S_ShrubBlank1
    elsif /(neg)|(blank)/i.match?(sample)
      nil

    # NOTE: X12S_MWWS_H0.54.S54.L001 or X12S_K0723_A1.10.S10.L001
    elsif /^.*?\.\d+\.S\d+\.L\d{3}$/.match?(cell)
      match = /(.*?)\.\d+\.S\d+\.L\d{3}/.match(cell)
      parts = match[1].split('_')
      if parts.length == 3
        "#{parts[1]}-#{parts[2]}"
      else
        "#{parts[0]}-#{parts[1]}"
      end

    elsif /^K\d{1,4}/.match?(sample)
      raise ImportError, "#{sample}: invalid sample format"
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def form_barcode(raw_string)
    raw_barcode = raw_string.strip

    # handles "K0030 B1"
    if raw_barcode.include?(' ')
      parts = raw_barcode.split(' ')
      kit = parts.first
      location_letter = parts.second.split('').first
      sample_number = parts.second.split('').second
      "#{kit}-L#{location_letter}-S#{sample_number}"

    # handles "K0030B1"
    elsif /^K\d{4}\w\d$/.match?(raw_barcode)
      match = /(K\d{4})(\w)(\d)/.match(raw_barcode)
      kit = match[1]
      location_letter = match[2]
      sample_number = match[3]
      "#{kit}-L#{location_letter}-S#{sample_number}"
    else
      raw_barcode
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def find_canonical_taxon_from_string(taxonomy_string)
    new_string = remove_na(taxonomy_string)
    new_string.split(';').last
  end

  def remove_na(taxonomy_string)
    new_string = taxonomy_string.dup
    new_string.gsub!(/;NA;/, ';;') while new_string.include?(';NA;')
    new_string.gsub!(/;NA$/, ';')
    new_string.gsub!(/^NA;/, ';')
    new_string
  end

  private

  def get_taxon_rank(taxonomy_string)
    if phylum_taxonomy_string?(taxonomy_string)
      get_taxon_rank_phylum(taxonomy_string)
    else
      get_taxon_rank_superkingdom(taxonomy_string)
    end
  end

  def get_hierarchy(taxonomy_string)
    if phylum_taxonomy_string?(taxonomy_string)
      get_hierarchy_phylum(taxonomy_string)
    else
      get_hierarchy_superkingdom(taxonomy_string)
    end
  end

  def get_kingdom(taxon)
    taxon.hierarchy_names['kingdom']
  end

  def get_superkingdom(taxon)
    taxon.hierarchy_names['superkingdom']
  end
end

class TaxaError < StandardError
end
