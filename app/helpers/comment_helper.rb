module CommentHelper
  def comment_form_id(comment)
    if comment.previously_new_record? || comment.new_record?
      if comment.parent_id
        "comment-#{comment.parent_id}-new-form"
      else
        "comment-new-form"
      end
    else
      "comment-#{comment.parent_id}-form"
    end
  end
end
