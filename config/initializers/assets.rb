class AssetUrlProcessor
  def self.call(input)
    context = input[:environment].context_class.new(input)

    data = input[:data].gsub(/url\((.+?)\)/) do |match|
      path = context.asset_path($1)
      "url(#{path})"
    end

    { data: data }
  end
end

Sprockets.register_postprocessor 'text/css', AssetUrlProcessor
