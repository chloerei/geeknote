class ReadPostTool < RubyLLM::Tool
  description "This tool reads a post for current convesation. It returns the post's content and metadata."

  def initialize(post)
    @post = post
  end

  def execute
    {
      title: @post.title,
      content: @post.content
    }
  end
end
