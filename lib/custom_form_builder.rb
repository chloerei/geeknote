class CustomFormBuilder < ActionView::Helpers::FormBuilder
  [:text_field, :password_field, :text_area, :number_field].each do |method|
    define_method(method) do |attribute, options = {}|
      klass = ['text-field', 'text-field--outlined']
      klass << 'text-field--invalid' if object && object.errors[attribute].any?
      klass << 'text-field--with-prefix-text' if options[:prefix_text]
      klass << 'text-field--with-suffix-text' if options[:suffix_text]
      @template.content_tag(:div, class: klass) do
        @template.concat(
          @template.content_tag(:div, class: 'text-field__container') do
            if options[:prefix_text]
              @template.concat @template.content_tag 'div', options[:prefix_text], class: 'text-field__prefix-text'
            end
            @template.concat super(attribute, options.merge(placeholder: ' '))
            @template.concat label(attribute, options[:label], class: 'text-field__label')
            if options[:suffix_text]
              @template.concat @template.content_tag 'div', options[:suffix_text], class: 'text-field__suffix-text'
            end
          end
        )

        if error_text = object && object.errors[attribute].first
          @template.concat @template.content_tag(:div, error_text, class: 'text-field__error-text')
        elsif options[:helper_text]
          @template.concat @template.content_tag(:div, options[:helper_text], class: 'text-field__helper-text')
        end
      end
    end
  end

  def check_box(attribute, options = {}, checked_value = '1', unchecked_value = '0')
    @template.content_tag(:label, class: 'checkbox') do
      super(attribute, options, checked_value, unchecked_value) +
      @template.content_tag(:div, class: 'checkbox__icon') do
        <<~EOF.html_safe
          <svg viewBox="0 0 24 24">
            <path fill="none" d="M1.73,12.91 8.1,19.28 22.79,4.59"/>
          </svg>
        EOF
      end
    end
  end

  def radio_button(attribute, tag_value, options = {})
    @template.content_tag(:label, class: 'radio') do
      super(attribute, tag_value, options) +
      @template.content_tag(:div, class: 'radio__icon') do
      end
    end
  end
end
