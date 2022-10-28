class Account::Posts::SocialImagesController < Account::Posts::BaseController
  layout false

  def show
    respond_to do |format|
      format.html

      format.png do
        html = render_to_string formats: :html

        Puppeteer.launch do |browser|
          image = future do
            page = browser.new_page
            page.viewport = Puppeteer::Viewport.new(width: 1280, height: 720, device_scale_factor: 2)
            page.set_content html, timeout: 5000
            page.screenshot
          end
          send_data await(image), type: 'image/png', disposition: 'inline'
        end
      end
    end
  end
end
