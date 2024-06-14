namespace :data do
  desc "Generate post revision for exists post"
  task generate_post_revision: :environment do
    Post.find_each do |post|
      post.save_revision(
        status: post.published? ? "published" : "draft",
        user: post.user
      )
    end
  end
end
