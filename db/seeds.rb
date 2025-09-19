# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development?
  user = User.create!(
    name: "Dev",
    email: "dev@example.com",
    password: "password",
    account_attributes: {
      name: "dev"
    }
  )

  post = Post.create!(
    account: user.account,
    user: user,
    status: "published",
    published_at: Time.now,
    title: "README",
    content: File.read(Rails.root.join("README.md")),
    tag_list: "Ruby, JavaScript",
  )

  Comment.create!(
    commentable: post,
    user: user,
    content: "This is a comment on the README post."
  )
end
