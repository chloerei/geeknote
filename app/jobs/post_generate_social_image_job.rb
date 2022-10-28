class PostGenerateSocialImageJob < ApplicationJob
  queue_as :low

  def perform(post)
    renderer = Account::Posts::SocialImagesController.renderer.new http_host: ENV['HOST'], https: ENV['FORCE_SSL'].present?
    html = renderer.render :show, assigns: { post: post, site: Site.first_or_create }
    Puppeteer.launch do |browser|
      image = future do
        page = browser.new_page
        page.viewport = Puppeteer::Viewport.new(width: 1280, height: 720, device_scale_factor: 2)
        page.set_content html, timeout: 5000
        page.screenshot
      end

      post.social_image.attach io: StringIO.new(await(image)), filename: "social_image.png", content_type: 'image/png'
    end
  end
end
