require "administrate/base_dashboard"

class PageDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    body: TextEditorField,
    published: Field::Boolean,
    menu_cd: EnumField,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    display_order: Field::Number,
    slug: Field::String,
    research_project: Field::BelongsTo,
    menu_text: Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = [
    :title,
    :published,
    :research_project,
  ].freeze

  SHOW_PAGE_ATTRIBUTES = [
    :title,
    :published,
    :menu_cd,
    :menu_text,
    :slug,
    :display_order,
    :research_project,
    :body,
    :created_at,
    :updated_at
  ].freeze

  FORM_ATTRIBUTES = [
    :title,
    :published,
    :menu_cd,
    :menu_text,
    :display_order,
    :slug,
    :research_project,
    :body,
  ].freeze

  def display_resource(page)
    page.title
  end
end
