# frozen_string_literal: true

class TaxaController < ApplicationController
  def index
    # TODO: r-enable highlights
    # @highlights = Highlight.asv
    @highlights = []
    @top_taxa = top_taxa
    @top_plant_taxa = top_plant_taxa
    @top_animal_taxa = top_animal_taxa
  end

  def show
    @taxon = taxon
    @samples = paginated_samples
    @asvs_count = asvs_count
  end

  private

  def asvs_count
    sql = 'SELECT sample_id, COUNT(*) ' \
          'FROM asvs ' \
          'JOIN extractions ' \
          'ON asvs.extraction_id = extractions.id ' \
          "WHERE \"taxonID\" = #{params[:id]} " \
          'GROUP BY sample_id '
    @asvs_count ||= ActiveRecord::Base.connection.execute(sql)
  end

  def top_taxa
    @top_taxa ||= ordered_taxa.sort_by { |t| sort_taxa_fields(t) }
  end

  def top_plant_taxa
    division = NcbiDivision.find_by(name: 'Plants')
    return [] if division.blank?
    @top_plant_taxa ||= ordered_taxa.where(cal_division_id: division.id)
                                    .sort_by { |t| sort_taxa_fields(t) }
  end

  def top_animal_taxa
    division = NcbiDivision.find_by(name: 'Animals')
    return [] if division.blank?
    @top_animal_taxa ||= ordered_taxa.where(cal_division_id: division.id)
                                     .sort_by { |t| sort_taxa_fields(t) }
  end

  def taxon
    @taxon ||= NcbiNode.includes(:ncbi_names).find(params[:id])
  end

  def ordered_taxa
    @ordered_taxa ||= NcbiNode.includes(:ncbi_names).order(asvs_count: :desc)
                              .limit(10)
  end

  def sort_taxa_fields(taxon)
    [
      -taxon.asvs_count,
      taxon.kingdom, taxon.phylum, taxon.className, taxon.order, taxon.family,
      taxon.genus, taxon.species
    ].compact
  end

  def paginated_samples
    if params[:view]
      Kaminari.paginate_array(samples).page(params[:page])
    else
      samples
    end
  end

  def raw_samples
    sql = sql_select + sql_where
    @raw_samples ||= ActiveRecord::Base.connection.execute(sql)
  end

  def samples
    groups = raw_samples.group_by { |t| t['id'] }.values
    @samples ||= groups.map do |g|
      OpenStruct.new(g.first.merge(taxons: g.pluck('canonicalName', 'taxonID')))
    end
  end

  def sql_select
    'SELECT samples.id, samples.barcode, ' \
    'asvs."taxonID" as "taxonID", ncbi_nodes."canonical_name", ' \
    'samples.latitude, samples.longitude, field_data_project_id, ' \
    'field_data_projects.name as field_data_project_name ' \
    'FROM asvs ' \
    'INNER JOIN ncbi_nodes ON asvs."taxonID" = ncbi_nodes."taxon_id" ' \
    'INNER JOIN extractions ON asvs.extraction_id = extractions.id ' \
    'INNER JOIN samples ON samples.id = extractions.sample_id ' \
    'INNER JOIN field_data_projects ON samples.field_data_project_id ' \
    ' = field_data_projects.id '
  end

  def sql_where
    # Match any of the ids in the first 100 arrays in lineage
    'WHERE samples.missing_coordinates = false ' \
    "AND '{#{params[:id]}}'::text[] <@ lineage[100][1:1]; "
  end

  def query_string
    query = {}
    project_id = params[:field_data_project_id]
    query[:field_data_project_id] = project_id if project_id
    query
  end
end
