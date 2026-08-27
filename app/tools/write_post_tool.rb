class WritePostTool < RubyLLM::Tool
  description "This tool write content to post for current conversation."

  parameter :title, description: "The title of the post."
  parameter :content, description: "The content of the post."

  def initialize(post)
    @post = post
  end

  def execute(title:, content:)
    @post.update(title: title, content: content)
    { success: true }
  end
end
