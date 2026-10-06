module AI
  # Suggests tags for a draft with a single one-shot LLM call.
  #
  # The site's most used tags are handed to the model as a vocabulary so it
  # reuses a tag that already exists instead of inventing a synonym for it.
  # Failures (network, provider, missing credentials) are raised to the caller,
  # which turns them into a user facing message.
  class TagSuggestion
    MAX_TAGS = 5
    POPULAR_TAGS_LIMIT = 30
    # Only the beginning of a long post is needed to tell what it is about.
    CONTENT_LIMIT = 8_000

    INSTRUCTIONS = <<~PROMPT
      You tag blog posts so readers can find related ones.

      Reply with the tags only, separated by commas: no numbering, no quotes, no
      explanations and no "#" prefix.

      Rules:
      - At most #{MAX_TAGS} tags, ordered from the most to the least relevant.
      - Write the tags in the same language as the post.
      - A tag is a short phrase of one to four words.
      - Reuse a tag from the existing tags list whenever one of them covers the
        topic, and never propose a synonym of an existing tag.
      - Only propose a new tag when no existing tag fits.
    PROMPT

    # Whether an AI model is configured. The editor hides its suggestion button
    # when it is not, and the endpoint refuses the request.
    def self.available?
      RubyLLM.config.default_model.present?
    end

    # The site's most used tags, offered to the model as its vocabulary. Tags
    # used by a single post are left out: they are too incidental to be worth
    # reusing.
    def self.popular_tags
      Tag
        .where("taggings_count > ?", 1)
        .order(taggings_count: :desc)
        .limit(POPULAR_TAGS_LIMIT)
        .pluck(:name)
    end

    def initialize(title:, content:)
      @title = title.to_s.strip
      @content = content.to_s.strip
    end

    def call
      return [] if @content.empty?

      parse(ask)
    end

    private

    def ask
      RubyLLM.chat
        # Tagging needs no deliberation, and the reasoning pass roughly triples
        # the wait for it.
        .with_thinking(false)
        .with_instructions(INSTRUCTIONS)
        .ask(prompt)
        .content
        .to_s
    end

    def prompt
      tags = self.class.popular_tags

      sections = []
      sections << "Existing tags: #{tags.join(', ')}" if tags.any?
      sections << "Title: #{@title}" if @title.present?
      sections << "Content:\n#{@content.truncate(CONTENT_LIMIT)}"
      sections.join("\n\n")
    end

    # The reply is the comma separated list the instructions ask for.
    def parse(reply)
      reply.split(",").map(&:strip).compact_blank
    end
  end
end
