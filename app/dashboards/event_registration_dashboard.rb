require "administrate/base_dashboard"

class EventRegistrationDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'username',
    ),
    event: Field::BelongsTo.with_options(
      searchable: true,
      searchable_field: 'name',
    ),
    id: Field::Number,
    status_cd: EnumField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :user,
    :event,
    :status_cd,
    :updated_at,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :user,
    :event,
    :status_cd,
    :created_at,
    :updated_at,
  ].freeze

  FORM_ATTRIBUTES = [
    :user,
    :event,
    :status_cd,
  ].freeze

  # def display_resource(event_registration)
  #   "EventRegistration ##{event_registration.id}"
  # end
end
