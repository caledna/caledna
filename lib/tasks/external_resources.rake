# frozen_string_literal: true

namespace :external_resources do
  require_relative '../../app/services/inat_api.rb'
  def api
    ::InatApi.new
  end

  task update_icun_status_for_dup_taxa: :environment do
    # change iucn_status for records where ncbi_id occur
    # more than once and one record has not null iucn_status;
    # (ncbi_id = 1, iucn_status = null) and (ncbi_id = 1, iucn_status = 'value')
    # => ncbi_id = 1, iucn_status = 'value'

    #  select count(*), ncbi_id, (ARRAY_AGG(distinct(iucn_status::text)))
    #  from external_resources
    #  group by ncbi_id
    #  having count(ncbi_id) > 1;

    sql = <<-SQL
      UPDATE external_resources
      SET iucn_status = subquery.iucn_status
      FROM (
        SELECT ncbi_id, iucn_status
        FROM external_resources
        WHERE ncbi_id IN (
          SELECT ncbi_id
          FROM external_resources
          GROUP BY ncbi_id
          HAVING count(ncbi_id) > 1
        )
        AND external_resources.iucn_status IS NOT NULL
      ) AS subquery
      WHERE external_resources.ncbi_id = subquery.ncbi_id
      AND external_resources.iucn_status IS NULL;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  task create_resources_for_inat_taxa: :environment do
    sql = <<-SQL
    SELECT canonical_name, taxon_id
    FROM external.inat_taxa
    LEFT JOIN external_resources
      ON external_resources.inaturalist_id = external.inat_taxa.taxon_id
    WHERE external_resources.inaturalist_id IS NULL
    GROUP BY canonical_name, taxon_id;
    SQL

    taxa = conn.exec_query(sql)

    taxa.each do |taxon|
      puts taxon['canonical_name']
      ExternalResource.create(search_term: taxon['canonical_name'],
                              inaturalist_id: taxon['taxon_id'],
                              source: 'iNaturalist')
    end
  end

  desc 'update inat_id for ncbi taxa where canonical_name matches and ' \
    'inat_id is null'
  task update_inat_id_for_ncbi_taxa: :environment do
    sql = <<-SQL
    SELECT  ncbi_nodes.taxon_id as ncbi_id, inat_taxa.taxon_id as inat_id
    FROM external_resources
    JOIN ncbi_nodes on ncbi_nodes.taxon_id = external_resources.ncbi_id
    join ncbi_divisions on ncbi_divisions.id = ncbi_nodes.cal_division_id
    JOIN external.inat_taxa as inat_taxa
      ON inat_taxa.canonical_name = ncbi_nodes.canonical_name
    WHERE external_resources.ncbi_id IS NOT NULL
    AND external_resources.inaturalist_id IS NULL
    and inat_taxa.kingdom = ncbi_divisions.name
    GROUP BY ncbi_nodes.taxon_id, inat_taxa.taxon_id
    SQL

    resources = conn.exec_query(sql)
    resources.each do |resource|
      puts resource['inat_id']

      update_external_resource_inat_id(inat_id: resource['inat_id'],
                                       ncbi_id: resource['ncbi_id'])
    end
  end

  task manually_update_inat_taxa: :environment do
    # set ncbi_id for Stenopelmatus "mahogany"
    sql1 = <<-SQL
    UPDATE external_resources SET ncbi_id=409502, updated_at = now()
    WHERE inaturalist_id = 534019;
    SQL

    # inat Reptilia has 3 ncbi taxa
    sql2 = <<-SQL
    INSERT INTO external_resources
    (ncbi_id , inaturalist_id, created_at, updated_at, source, search_term)
    VALUES(1294634, 26036, now(), now(), 'iNaturalist', 'Reptilia');
    SQL

    # inat Reptilia has 3 ncbi taxa
    sql3 = <<-SQL
    INSERT INTO external_resources
    (ncbi_id , inaturalist_id, created_at, updated_at, source, search_term)
    VALUES(8459, 26036, now(), now(), 'iNaturalist', 'Reptilia');
    SQL

    # change inat_id for Lotus
    sql4 = <<-SQL
    UPDATE external_resources SET inaturalist_id=47436, updated_at = now()
    WHERE ncbi_id = 3867;
    SQL

    # change inat_id for Cornus
    sql5 = <<-SQL
    UPDATE external_resources SET inaturalist_id=47193, updated_at = now()
    WHERE ncbi_id = 4281;
    SQL

    # set ncbi_id for Viburnaceae
    sql6 = <<-SQL
    UPDATE external_resources SET ncbi_id=4206, updated_at = now()
    WHERE inaturalist_id = 781703;
    SQL

    # set ncbi_id for Paradoxornithidae
    sql7 = <<-SQL
    UPDATE external_resources SET ncbi_id=36270, updated_at = now()
    WHERE inaturalist_id = 339898;
    SQL

    # set ncbi_id for Cornu
    sql8 = <<-SQL
    UPDATE external_resources SET ncbi_id=6534, updated_at = now()
    WHERE inaturalist_id = 87634;
    SQL

    # set ncbi_id for Cathartiformes
    sql9 = <<-SQL
    UPDATE external_resources SET ncbi_id=2558200, updated_at = now()
    WHERE inaturalist_id = 559244;
    SQL

    queries = [sql1, sql2, sql3, sql4, sql5, sql6, sql7, sql8, sql9]

    queries.each do |sql|
      conn.exec_query(sql)
    end
  end

  task fix_bad_inat_api_imports: :environment do
    taxa = [
      { name: 'Acmispon', rank: 'genus' },
      { name: 'Cornu', rank: 'genus' },
      { name: 'Malosma laurina', rank: 'species' }
    ]

    taxa.each do |taxon|
      name = taxon[:name]
      rank = taxon[:rank]

      api.get_taxa(name: name, rank: rank) do |results|
        record = results.select do |item|
          item['name'] == name && item['rank'] == rank
        end.first
        next if record.blank?

        InatTaxon.update(
          photo: record['default_photo'],
          wikipedia_url: record['wikipedia_url'],
          ids: record['ancestor_ids'],
          iconic_taxon_name: record['iconic_taxon_name'],
          common_name: record['preferred_common_name'],
          taxon_id: record['id']
        ).where(canonical_name: taxon[:name])
      end
    end
  end

  # step 1: add inat_id to higher ncbi taxa
  desc 'add inat api data to ncbi taxa'
  task add_inat_api_data_to_ncbi_taxa: :environment do
    # select higher taxa Eukaryota ncbi_nodes that do not have inat id
    sql = <<-SQL
    SELECT ncbi_nodes.rank, ncbi_nodes.canonical_name, ncbi_nodes.taxon_id ,
    external_resources.ncbi_id, external_resources.inaturalist_id
    FROM ncbi_nodes
    LEFT JOIN external_resources
      ON ncbi_nodes.taxon_id = external_resources.ncbi_id
    WHERE external_resources.inaturalist_id IS NULL
    AND ncbi_nodes.rank
      IN ('superkingdom', 'kingdom', 'phylum', 'class', 'order')
    AND (
      (ncbi_nodes.hierarchy_names ->> 'superkingdom')::Text = 'Eukaryota'
    )
    AND ncbi_nodes.taxon_id NOT IN (
      SELECT ncbi_id FROM external_resources WHERE inaturalist_id IS NOT NULL
    )
    GROUP BY ncbi_nodes.rank, ncbi_nodes.canonical_name, ncbi_nodes.taxon_id,
    external_resources.ncbi_id, external_resources.inaturalist_id
    ;
    SQL

    ncbi_taxa = conn.exec_query(sql)
    ncbi_taxa.each do |ncbi_taxon|
      sleep(0.5)
      name = ncbi_taxon['canonical_name']

      api.get_taxa(name: name, rank: nil) do |results|
        records = results.select do |item|
          item['name'] == name ||
            (!item['name'].start_with?(name) && !item['name'].include?(' '))
        end
        next if records.blank?
        puts name

        payload = records.map do |record|
          {
            id: record['id'],
            name: record['name'],
            rank: record['rank'],
            ancestry: record['ancestor_ids']
          }
        end

        payload = payload.first if payload.length == 1

        # update existing ExternalResource
        if ncbi_taxon['nbci_id'].present?
          ExternalResource
            .where(ncbi_id: ncbi_taxon['taxon_id'])
            .update(
              inat_payload: payload
            )
        # create new ExternalResource
        else
          ExternalResource.create(
            source: 'ncbi higher ranks',
            search_term: name,
            ncbi_id: ncbi_taxon['taxon_id'],
            inat_payload: payload
          )
        end
      end
    end
  end

  # step 2: add inat_id to higher ncbi taxa
  # - manually edit the api data when there are multiple records

  # step 3: add inat_id to higher ncbi taxa
  desc 'set inaturalist_id using inat api data'
  task use_inat_api_data_to_set_inat_id: :environment do
    sql = <<-SQL
    UPDATE external_resources
    SET inaturalist_id = ( inat_payload ->> 'id')::INTEGER
    WHERE inaturalist_id IS NULL
    AND inat_payload != '{}';
    SQL

    conn.exec_query(sql)
  end

  # step 4: add inat_id to higher ncbi taxa
  desc 'for ncbi_id that appear multiple times, grab inat_id from one of the ' \
  'records to fill in the inat_id for the other records'
  task fill_in_missing_inat_id_for_dup_ncbi_taxa: :environment do
    sql = <<-SQL
    UPDATE external_resources
    SET inaturalist_id = foo.inaturalist_id
    FROM (
      SELECT inaturalist_id, ncbi_id
      FROM external_resources
      WHERE inaturalist_id IS NOT NULL
      AND source  = 'ncbi higher ranks'
      AND ncbi_id IN (
        SELECT ncbi_id FROM external_resources WHERE inaturalist_id IS NULL
      )
    ) AS foo
    WHERE external_resources.ncbi_id = foo.ncbi_id
    AND external_resources.inaturalist_id
    ;
    SQL

    conn.exec_query(sql)
  end

  task delete_duplicate_ncbi_higher_ranks: :environment do
    sql = <<-SQL
    DELETE FROM external_resources
    WHERE id IN (
      SELECT (array_agg(id))[1]
      FROM external_resources
      WHERE (inat_payload != '{}')
      AND source = 'ncbi higher ranks'
      AND inaturalist_id IS NOT NULL
      GROUP BY ncbi_id, inat_payload
      HAVING count(*) > 1
    );
    SQL

    conn.exec_query(sql)
  end

  task fill_in_missing_search_term: :environment do
    resources =
      ExternalResource
      .where('search_term IS NULL')
      .joins('JOIN ncbi_nodes on ncbi_nodes.taxon_id = ' \
        'external_resources.ncbi_id')
      .select('external_resources.*, ncbi_nodes.canonical_name')

    resources.each do |resource|
      puts resource.canonical_name
      resource.update(search_term: resource.canonical_name)
    end
  end

  task fill_in_inat_images: :environment do
    sql = <<-SQL
      UPDATE external_resources
      SET inat_image = subquery.url, inat_image_attribution = subquery.source
      FROM (
        SELECT inat_taxa.photo ->> 'medium_url' AS url, inat_taxa.taxon_id,
        inat_taxa.photo ->> 'attribution' AS source
        FROM external.inat_taxa AS inat_taxa
        WHERE inat_taxa.photo ->> 'medium_url' IS NOT NULL
      ) AS subquery
      WHERE external_resources.inaturalist_id = subquery.taxon_id
      AND external_resources.inat_image IS NULL;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  task :add_eol_images, %i[path] => :environment do |_t, args|
    path = args[:path]

    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      next if row['eol_image'].blank?
      puts row['ncbi_id']
      resources = ExternalResource.where(ncbi_id: row['ncbi_id'])

      if resources.blank?
        attributes = {
          ncbi_id: row['ncbi_id'],
          search_term: row['canonical_name'],
          eol_image: row['eol_image'],
          eol_image_attribution: row['eol_image_attribution'],
          source: 'eol'
        }
        ExternalResource.create(attributes)
      else
        attributes = {
          eol_image: row['eol_image'],
          eol_image_attribution: row['eol_image_attribution']
        }
        resources.update(attributes)
      end
    end
  end

  task :add_inat_images_v1, %i[path] => :environment do |_t, args|
    path = args[:path]

    CSV.foreach(path, headers: true, col_sep: ',') do |row|
      next if row['inat_image'].blank?
      puts row['ncbi_id']
      resources = ExternalResource.where(ncbi_id: row['ncbi_id'])

      if resources.blank?
        attributes = {
          ncbi_id: row['inat_image'],
          search_term: row['canonical_name'],
          inat_image: row['inat_image'],
          inat_image_attribution: row['inat_image_attribution'],
          source: 'inat'
        }
        ExternalResource.create(attributes)
      else
        attributes = {
          inat_image: row['inat_image'],
          inat_image_attribution: row['inat_image_attribution']
        }
        resources.update(attributes)
      end
    end
  end

  task mark_as_inactive: :environment do
    sql = 'UPDATE external_resources SET active = false ' \
      "WHERE source != 'wikidata';"
    conn.exec_query(sql)
  end

  task add_gbif_id_to_external_resources_without_gbif_id: :environment do
    sql = <<~SQL
      update external_resources set gbif_id = temp.gbif_id from (
        select gbif_taxa.ncbi_id, gbif_taxa.gbif_id
        from external.gbif_taxa
        join external_resources
        on external_resources.ncbi_id = gbif_taxa.ncbi_id
        and external_resources.source = 'wikidata'
        and external_resources.active = true
        and external_resources.gbif_id is null
        where gbif_taxa.taxonomic_status = 'accepted'
      ) as temp
      where external_resources.ncbi_id = temp.ncbi_id
      and external_resources.source = 'wikidata'
      and external_resources.active = true
      and external_resources.gbif_id is null;
    SQL

    conn.exec_query(sql)
  end

  task create_external_resource_for_gbif_id: :environment do
    sql = <<~SQL
      insert into external_resources (ncbi_id, gbif_id, ncbi_name,
      search_term , source, created_at, updated_at, active)
      select gbif_taxa.ncbi_id, gbif_taxa.gbif_id, ncbi_nodes.canonical_name,
      ncbi_nodes.canonical_name, 'external.gbif_taxa', now(), now(), true
      from external.gbif_taxa
      join ncbi_nodes on ncbi_nodes.ncbi_id = gbif_taxa.ncbi_id
      where gbif_id in (
        select gbif_taxa.gbif_id
        from external.gbif_taxa
        where gbif_taxa.taxonomic_status = 'accepted'
        except
        select gbif_id
        from external_resources
        where gbif_id is not null
        and external_resources.wikidata_image is not null
        and external_resources.source = 'wikidata'
      );
    SQL

    conn.exec_query(sql)
  end

  task add_gbif_images: :environment do
    gbif_api = GbifApi.new
    inat_api = InatApi.new

    sql = <<~SQL
      select gbif_id
      from external_resources
      where active = true
      and wikidata_image is null
      and inat_image is null
      and gbif_id is not null
      group by gbif_id
      limit 1
    SQL

    results = conn.exec_query(sql)

    results.each do |result|
      gbif_response = gbif_api.inat_occurrence_by_taxon(result['gbif_id'])
      next if gbif_response['results'].blank?

      inat_taxon_id = gbif_response['results'].first['taxonID']
      photo_data = inat_api.default_photo(inat_taxon_id)

      sql = <<~SQL
        UPDATE external_resources
        set inat_image = $1, inat_image_attribution = $2, inat_image_id = $3,
        updated_at = now()
        where active = true
        and wikidata_image is null
        and inat_image is null
        and gbif_id = $4
      SQL

      binding = [[nil, photo_data[:url]], [nil, photo_data[:attribution]],
                 [nil, photo_data[:photo_id]], [nil, result['gbif_id']]]
      conn.exec_query(sql, 'q', binding)
    end
  end

  task add_inat_images: :environment do
    select_sql = <<~SQL
      select inaturalist_id
      from external_resources
      where active = true
      and wikidata_image is null
      and inat_image is null
      and inaturalist_id is not null
      and source = 'wikidata'
    SQL

    results = conn.exec_query(select_sql)
    results.each.with_index do |result, index|
      delay = index * 1.1
      UpdateInatImageJob.set(wait: delay.seconds)
                        .perform_later(result['inaturalist_id'])
    end
  end

  private

  def conn
    @conn ||= ActiveRecord::Base.connection
  end

  def update_external_resource_inat_id(inat_id:, ncbi_id:, note: nil)
    sql = <<-SQL
    UPDATE external_resources
    SET inaturalist_id = #{inat_id},
      updated_at = now(),
      notes = case when "notes" is null or trim("notes")=''
        then '#{note}' else "notes" || '; ' || '#{note}' end
    WHERE ncbi_id = #{ncbi_id}
    AND inaturalist_id IS NULL;
    SQL
    conn.exec_query(sql)
  end
end
