class CustomFormBuilder < ActionView::Helpers::FormBuilder
  [:text_field, :password_field, :text_area, :number_field].each do |method|
    define_method(method) do |attribute, options = {}|
      klass = ['text-field', 'text-field--filled']
      klass << 'text-field--invalid' if object && object.errors[attribute].any?
      @template.content_tag(:div, class: klass) do
        @template.content_tag(:div, class: 'text-field__container') do
          super(attribute, options.merge(placeholder: ' ')) +
          label(attribute, options[:label], class: 'text-field__label')
        end +
        @template.content_tag(:div, class: 'text-field__helper-text') do
          options[:helper_text]
        end +
        @template.content_tag(:div, class: 'text-field__error-text') do
          object && object.errors[attribute].first
        end
      end
    end
  end

  def check_box(attribute, options = {})
    @template.content_tag(:label, class: 'checkbox') do
      super(attribute, options) +
      @template.content_tag(:div, class: 'checkbox__icon') do
        <<~EOF.html_safe
          <svg viewBox="0 0 24 24">
            <path fill="none" d="M1.73,12.91 8.1,19.28 22.79,4.59"/>
          </svg>
        EOF
      end
    end
  end
end
