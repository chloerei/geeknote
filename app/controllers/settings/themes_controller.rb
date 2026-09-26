class Settings::ThemesController < Settings::BaseController
  def show
    @page_titles.prepend t("general.theme")
  end
end
