require "administrate/base_dashboard"

class ExtractionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    sample: Field::BelongsTo,
    extraction_type: Field::BelongsTo,
    processor: Field::BelongsTo.with_options(class_name: "Researcher"),
    asvs: Field::HasMany,
    id: Field::Number,
    processor_id: Field::Number,
    priority_sequencing_cd: EnumField,
    prepub_share: Field::Boolean,
    prepub_share_group: Field::String,
    prepub_filter_sensitive_info: Field::Boolean,
    sra_url: Field::String,
    sra_adder_id: Field::Number,
    sra_add_date: Field::DateTime,
    local_fastq_storage_url: Field::String,
    local_fastq_storage_adder_id: Field::Number,
    local_fastq_storage_add_date: Field::DateTime,
    stat_bio_reps_pooled: Field::Boolean,
    stat_bio_reps_pooled_date: Field::DateTime,
    loc_bio_reps_pooled: Field::String,
    bio_reps_pooled_date: Field::DateTime,
    protocol_bio_reps_pooled: Field::String,
    changes_protocol_bio_reps_pooled: Field::String,
    stat_dna_extraction: Field::Boolean,
    stat_dna_extraction_date: Field::DateTime,
    loc_dna_extracts: Field::String,
    dna_extraction_date: Field::DateTime,
    protocol_dna_extraction: Field::String,
    changes_protocol_dna_extraction: Field::String,
    metabarcoding_primers: Field::String,
    stat_barcoding_pcr_done: Field::Boolean,
    stat_barcoding_pcr_done_date: Field::DateTime,
    barcoding_pcr_number_of_replicates: Field::Number,
    reamps_needed: Field::Boolean,
    stat_barcoding_pcr_pooled: Field::Boolean,
    stat_barcoding_pcr_pooled_date: Field::DateTime,
    stat_barcoding_pcr_bead_cleaned: Field::Boolean,
    stat_barcoding_pcr_bead_cleaned_date: Field::DateTime,
    brand_beads_cd: EnumField,
    cleaned_concentration: Field::String.with_options(searchable: false),
    loc_stored: Field::String,
    select_indices_cd: EnumField,
    index_1_name: Field::String,
    index_2_name: Field::String,
    stat_index_pcr_done: Field::Boolean,
    stat_index_pcr_done_date: Field::DateTime,
    stat_index_pcr_bead_cleaned: Field::Boolean,
    stat_index_pcr_bead_cleaned_date: Field::DateTime,
    index_brand_beads_cd: EnumField,
    index_cleaned_concentration: Field::String.with_options(searchable: false),
    index_loc_stored: Field::String,
    stat_libraries_pooled: Field::Boolean,
    stat_libraries_pooled_date: Field::DateTime,
    loc_libraries_pooled: Field::String,
    stat_sequenced: Field::Boolean,
    stat_sequenced_date: Field::DateTime,
    intended_sequencing_depth_per_barcode: Field::String,
    sequencing_platform_cd: EnumField,
    assoc_field_blank: Field::String,
    assoc_extraction_blank: Field::String,
    assoc_pcr_blank: Field::String,
    notes_sample_processor: Field::String,
    notes_lab_manager: Field::String,
    notes_director: Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :sample,
    :processor,
    :asvs,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :sample,
    :extraction_type,
    :processor,
    :asvs,
    :id,
    :processor_id,
    :priority_sequencing_cd,
    :prepub_share,
    :prepub_share_group,
    :prepub_filter_sensitive_info,
    :sra_url,
    :sra_adder_id,
    :sra_add_date,
    :local_fastq_storage_url,
    :local_fastq_storage_adder_id,
    :local_fastq_storage_add_date,
    :stat_bio_reps_pooled,
    :stat_bio_reps_pooled_date,
    :loc_bio_reps_pooled,
    :bio_reps_pooled_date,
    :protocol_bio_reps_pooled,
    :changes_protocol_bio_reps_pooled,
    :stat_dna_extraction,
    :stat_dna_extraction_date,
    :loc_dna_extracts,
    :dna_extraction_date,
    :protocol_dna_extraction,
    :changes_protocol_dna_extraction,
    :metabarcoding_primers,
    :stat_barcoding_pcr_done,
    :stat_barcoding_pcr_done_date,
    :barcoding_pcr_number_of_replicates,
    :reamps_needed,
    :stat_barcoding_pcr_pooled,
    :stat_barcoding_pcr_pooled_date,
    :stat_barcoding_pcr_bead_cleaned,
    :stat_barcoding_pcr_bead_cleaned_date,
    :brand_beads_cd,
    :cleaned_concentration,
    :loc_stored,
    :select_indices_cd,
    :index_1_name,
    :index_2_name,
    :stat_index_pcr_done,
    :stat_index_pcr_done_date,
    :stat_index_pcr_bead_cleaned,
    :stat_index_pcr_bead_cleaned_date,
    :index_brand_beads_cd,
    :index_cleaned_concentration,
    :index_loc_stored,
    :stat_libraries_pooled,
    :stat_libraries_pooled_date,
    :loc_libraries_pooled,
    :stat_sequenced,
    :stat_sequenced_date,
    :intended_sequencing_depth_per_barcode,
    :sequencing_platform_cd,
    :assoc_field_blank,
    :assoc_extraction_blank,
    :assoc_pcr_blank,
    :notes_sample_processor,
    :notes_lab_manager,
    :notes_director,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :sample,
    :extraction_type,
    :processor,
    :asvs,
    :processor_id,
    :priority_sequencing_cd,
    :prepub_share,
    :prepub_share_group,
    :prepub_filter_sensitive_info,
    :sra_url,
    :sra_adder_id,
    :sra_add_date,
    :local_fastq_storage_url,
    :local_fastq_storage_adder_id,
    :local_fastq_storage_add_date,
    :stat_bio_reps_pooled,
    :stat_bio_reps_pooled_date,
    :loc_bio_reps_pooled,
    :bio_reps_pooled_date,
    :protocol_bio_reps_pooled,
    :changes_protocol_bio_reps_pooled,
    :stat_dna_extraction,
    :stat_dna_extraction_date,
    :loc_dna_extracts,
    :dna_extraction_date,
    :protocol_dna_extraction,
    :changes_protocol_dna_extraction,
    :metabarcoding_primers,
    :stat_barcoding_pcr_done,
    :stat_barcoding_pcr_done_date,
    :barcoding_pcr_number_of_replicates,
    :reamps_needed,
    :stat_barcoding_pcr_pooled,
    :stat_barcoding_pcr_pooled_date,
    :stat_barcoding_pcr_bead_cleaned,
    :stat_barcoding_pcr_bead_cleaned_date,
    :brand_beads_cd,
    :cleaned_concentration,
    :loc_stored,
    :select_indices_cd,
    :index_1_name,
    :index_2_name,
    :stat_index_pcr_done,
    :stat_index_pcr_done_date,
    :stat_index_pcr_bead_cleaned,
    :stat_index_pcr_bead_cleaned_date,
    :index_brand_beads_cd,
    :index_cleaned_concentration,
    :index_loc_stored,
    :stat_libraries_pooled,
    :stat_libraries_pooled_date,
    :loc_libraries_pooled,
    :stat_sequenced,
    :stat_sequenced_date,
    :intended_sequencing_depth_per_barcode,
    :sequencing_platform_cd,
    :assoc_field_blank,
    :assoc_extraction_blank,
    :assoc_pcr_blank,
    :notes_sample_processor,
    :notes_lab_manager,
    :notes_director,
  ].freeze

  # Overwrite this method to customize how extractions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(extraction)
  #   "Extraction ##{extraction.id}"
  # end
end
