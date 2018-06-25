module PagesHelper
  def self.about_links
    menu_link(:about)
  end

  def self.explore_data
    menu_link(:explore_data)
  end

  def self.get_involved_links
    menu_link(:get_involved)
  end

  def self.menu_link(menu)
    Page.where(menu_cd: menu, published: true).order(:order).map do |page|
      { slug: page.slug, title: page.title }
    end
  end
end
