class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless url_valid?(value)
      record.errors.add attribute, (options[:message] || :invalid_url)
    end
  end

  def url_valid?(value)
    uri = URI.parse(value) rescue nil
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  end
end
