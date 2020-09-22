# frozen_string_literal: true

class Place < ApplicationRecord
  belongs_to :place_source, optional: true
  has_many :place_pages
  has_one_attached :image

  as_enum :place_type, %i[state watershed county place neighborhood UCNRS
                          zip_code river ecoregions_l3 ecoregions_l4 ecotopes
                          pour_location],
          map: :string
  as_enum :place_source_type, %i[census USGS UCNRS LA_neighborhood
                                 LA_zip_code LA_river EPA LASAN],
          map: :string

  validates :name, :place_type,
            :place_source_type, presence: true

  before_save do
    if geom.blank? && longitude.present? && latitude.present?
      self.geom = "POINT(#{longitude} #{latitude})"
    end

    if point_geom? && (latitude_changed? || longitude_changed?)
      self.geom = "POINT(#{longitude} #{latitude})"
    end
  end

  after_save do
    sql = 'UPDATE places SET geom_projected = ST_Transform(ST_SetSRID' \
      "(geom, #{Geospatial::SRID}), #{Geospatial::SRID_PROJECTED}) " \
      "WHERE id = #{id}"

    ActiveRecord::Base.connection.exec_query(sql)
  end

  def show_pages?
    place_pages.published.present?
  end

  def default_page
    pages = place_pages.published.order('display_order ASC NULLS LAST') || []
    @default_page ||= pages.first
  end

  private

  def point_geom?
    geom.class == RGeo::Geos::CAPIPointImpl
  end
end
