# frozen_string_literal: true

module KoboApi
  module Process
    def import_kobo_projects(hash_payload)
      results = hash_payload.map do |project_data|
        next if project_ids.include?(project_data['id'])
        save_project_data(project_data)
      end
      results.compact.all? { |r| r }
    end

    def import_kobo_samples(project_id, kobo_id, hash_payload)
      counter = 0
      hash_payload.map do |sample_data|
        next if kobo_sample_ids.include?(sample_data['_id'])
        counter += 1
        ImportKoboSampleJob.perform_later(project_id, kobo_id, sample_data)
      end
      counter
    end

    def save_project_data(hash_payload)
      data = OpenStruct.new(hash_payload)
      project = ::FieldDataProject.new(
        name: data.title,
        description: data.description,
        kobo_id: data.id,
        kobo_payload: hash_payload,
        last_import_date: Time.zone.now
      )

      project.save
    end

    def save_sample_data(field_data_project_id, kobo_id, hash_payload)
      case kobo_id
      when 95_481, 87_534, 95_664, 83_937
        process_multi_samples(field_data_project_id, hash_payload)
      when 136_577, 130_560, 138_676, 170_620
        process_single_sample_v1(field_data_project_id, hash_payload)
      else
        process_single_sample_v2(field_data_project_id, hash_payload)
      end
    end

    private

    def project_ids
      FieldDataProject.pluck(:kobo_id)
    end

    def clean_kit_number(kit_number)
      clean_kit_number = kit_number
      clean_kit_number.try(:upcase)
    end

    def kobo_sample_ids
      Sample.pluck(:kobo_id)
    end

    def non_kobo_barcodes
      Sample.where(kobo_id: nil).pluck(:barcode)
    end

    def project(kobo_id)
      Project.find_by(kobo_id: kobo_id)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def sample_prefixes
      [
        { gps: 'groupA/A1/A1gps', other: 'groupA/A1/A1', tube: 'LA-S1' },
        { gps: 'groupA/A2/A2gps', other: 'groupA/A2/A2', tube: 'LA-S2' },
        { gps: 'groupB/B1/barcodesB1/B1gps', other: 'groupB/B1/B1',
          tube: 'LB-S1' },
        { gps: 'groupB/B2/barcodesB2/B2gps', other: 'groupB/B2/B2',
          tube: 'LB-S2' },
        { gps: 'locC1/C1/barcodesC1/C1gps', other: 'locC1/C1/C1',
          tube: 'LC-S1' },
        { gps: 'locC1/C2/barcodesC2/C2gps', other: 'locC1/C2/C2',
          tube: 'LC-S2' }
      ]
    end

    def process_single_sample_v1(field_data_project_id, hash_payload)
      data = OpenStruct.new(hash_payload)
      kit_number = clean_kit_number(data.What_is_your_kit_number_e_g_K0021)
      location_letter = data.Which_location_lette_codes_LA_LB_or_LC.try(:upcase)
      site_number = data.You_re_at_your_first_r_barcodes_S1_or_S2.try(:upcase)
      data.barcode = "#{kit_number}-#{location_letter}-#{site_number}"
      data.gps = data.Get_the_GPS_Location_e_this_more_accurate
      data.substrate = data.What_type_of_substrate_did_you
      data.field_notes = [
        data.Notes_on_recent_mana_the_sample_location,
        data._Optional_Regarding_rns_to_share_with_us
      ].compact.join(' ')
      data.location = [
        data.Where_are_you_A_UC_serve_or_in_Yosemite,
        data.Location
      ].compact.join(' ')
      data.field_data_project_id = field_data_project_id

      sample = save_sample(data, hash_payload)
      save_photos(sample.id, hash_payload)
    end

    def process_single_sample_v2(field_data_project_id, hash_payload)
      data = OpenStruct.new(hash_payload)
      kit_number = clean_kit_number(data.What_is_your_kit_number_e_g_K0021)
      location_letter = data.Which_location_lette_codes_LA_LB_or_LC.try(:upcase)
      site_number = data.You_re_at_your_first_r_barcodes_S1_or_S2.try(:upcase)
      data.barcode = "#{kit_number}-#{location_letter}-#{site_number}"
      data.gps = data.Get_the_GPS_Location_e_this_more_accurate
      data.substrate = data.What_type_of_substrate_did_you
      data.field_notes = data._Optional_Regarding_rns_to_share_with_us
      data.location = [
        data.Where_are_you_A_UC_serve_or_in_Yosemite,
        data.Location
      ].compact.join(' ')
      data.field_data_project_id = field_data_project_id
      data.habitat = data._optional_Describe_ou_are_sampling_from
      data.depth = data._optional_What_dept_re_your_samples_from
      data.environmental_features = [
        data.Choose_from_common_environment,
        data.If_other_describe_t_nvironmental_feature
      ].compact.join(' ')
      data.environmental_settings =
        data.Describe_the_environ_tions_from_this_list

      sample = save_sample(data, hash_payload)
      save_photos(sample.id, hash_payload)
    end

    def process_multi_samples(field_data_project_id, hash_payload)
      data = OpenStruct.new(hash_payload)
      kit_number = clean_kit_number(data.kit || '')

      sample_prefixes.each do |prefix|
        data.barcode = "#{kit_number}-#{prefix[:tube]}"
        data.gps = data.send(prefix[:gps]) || ''
        data.substrate = data.send("#{prefix[:other]}SS")
        data.field_notes = data.send("#{prefix[:other]}comments")
        data.location =
          [data.somewhere, data.where, data.reserves].compact.join('; ')
        data.field_data_project_id = field_data_project_id

        sample = save_sample(data, hash_payload)
        photo_payload = find_photos(prefix[:other], hash_payload)
        save_photos(sample.id, _attachments: photo_payload)
      end
    end

    def find_photos(prefix, hash_payload)
      photo_filenames = hash_payload.select do |key|
        key.starts_with?("#{prefix}picgroup")
      end.values

      photo_filenames.flat_map do |filename|
        hash_payload['_attachments'].select do |attachment|
          attachment['filename'].ends_with?(filename)
        end
      end
    end

    def save_sample(data, hash_payload)
      sample_data = {
        field_data_project_id: data.field_data_project_id,
        kobo_id: data._id,
        kobo_data: hash_payload,
        collection_date: data.Enter_the_sampling_date_and_time,
        submission_date: data._submission_time,
        location: data.location,
        latitude: data.gps.split.first,
        longitude: data.gps.split.second,
        altitude: data.gps.split.third,
        gps_precision: data.gps.split.fourth,
        substrate: data.substrate,
        field_notes: data.field_notes,
        habitat: data.habitat,
        depth: data.depth,
        environmental_features: data.environmental_features,
        environmental_settings: data.environmental_settings
      }

      if non_kobo_barcodes.include?(data.barcode)
        ::Sample.update(sample_data).where(barcode: data.barcode)
      else
        sample_data[:status] = :submitted
        sample_data[:barcode] = data.barcode
        ::Sample.create(sample_data)
      end
    end

    def save_photos(sample_id, hash_payload)
      data = OpenStruct.new(hash_payload)

      photos_data = data._attachments
      photos_data.map do |photo_data|
        data = OpenStruct.new(photo_data)

        filename = data.filename.split('/').last
        photo = ::Photo.new(
          file_name: filename,
          source_url: "#{ENV.fetch('KOBO_MEDIA_URL')}#{data.filename}",
          kobo_payload: data,
          sample_id: sample_id
        )

        photo.save
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end

# PROJECT = {
#   '98565': ['Yosemite', '?', '0 records'],
#   '154164': ['Mojave_CALeDNA / CALeDNA Mojave Bioblitz 1', '?', '0 records'],

#   '95481': ['CALeDNA_test20170418 / CALeDNA Coastal Bioblitz 1',
#   'MULTI_SAMPLE_FIELDS_A', '5 records'],
#   '87534': ['Welcome to CALeDNA! / CALeDNA Spring Bioblitz 1',
#   'MULTI_SAMPLE_FIELDS_A', '50 records'],
#   '95664': ['CALeDNA_test20170419 / CALeDNA Bioblitz Spring and Fall 1',
#   'MULTI_SAMPLE_FIELDS_A', '40 records'],
#   '83937': ['CALeDNA_iOS / Pillar_Point_1', 'MULTI_SAMPLE_FIELDS_A',
#   '12 records'],

#   '138676': ['CALeDNA mountains / CALeDNA Mountain Bioblitz 1',
#   'SINGLE_SAMPLE_FIELDS_v1', '24 records'],
#   '130560': ['Sedgwick / CALeDNA Fall Bioblitz 1',
#   'SINGLE_SAMPLE_FIELDS_v1', '173 records'],
#   '136577': ['CALeDNA coastal / CALeDNA Coastal Bioblitz 2',
#   'SINGLE_SAMPLE_FIELDS_v1', '86 records'],
#   '170620': ['younger lagoon', 'SINGLE_SAMPLE_FIELDS_v1', '86 records'],

#   '168570': ['CALeDNA 2018', 'MULTI_SAMPLE_FIELDS_v2', '40 records'],
# }
