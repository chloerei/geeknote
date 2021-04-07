Kaminari.configure do |config|
  # config.default_per_page = 25
  # config.max_per_page = nil
  config.window = 2
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  # config.max_pages = nil
  # config.params_on_first_page = false
end

class Kaminari::Helpers::Paginator
  # alway display pagination
  def render(&block)
    instance_eval(&block)
    @output_buffer
  end
end
