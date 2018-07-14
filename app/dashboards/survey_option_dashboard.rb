# frozen_string_literal: true

require 'administrate/base_dashboard'

class SurveyOptionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    survey_question: Field::BelongsTo,
    id: Field::Number,
    content: Field::Text,
    accepted_answer: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :survey_question,
    :content,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :survey_question,
    :content,
    :accepted_answer,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :survey_question,
    :content,
    :accepted_answer,
  ].freeze

  # def display_resource(survey_option)
  #   "SurveyOption ##{survey_option.id}"
  # end
end
