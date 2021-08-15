class CollectionItem < ApplicationRecord
  belongs_to :collection, touch: true, counter_cache: true
  belongs_to :post

  after_create do
    collection.with_lock do
      case collection.order_type
      when 'custom'
        case collection.add_to
        when 'top'
          collection.collection_items.update_all "position = position + 1"
          update_attribute :position, 0
        when 'bottom'
          last = collection.collection_items.maximum("position")
          update_attribute :position, last ? last + 1 : 0
        end
      when 'added_asc'
        last = collection.collection_items.maximum("position")
        update_attribute :position, last ? last + 1 : 0
      when 'added_desc'
        collection.collection_items.update_all "position = position + 1"
        update_attribute :position, 0
      when 'published_asc'
        before = collection.collection_items.joins(:post).where("posts.published_at < ?", post.published_at).maximum("position")
        position = before ? before + 1 : 0
        collection.collection_items.where("position >= ?", position).update_all("position = position + 1")
        update_attribute :position, position
      when 'published_desc'
        before = collection.collection_items.joins(:post).where("posts.published_at > ?", post.published_at).maximum("position")
        position = before ? before + 1 : 0
        collection.collection_items.where("position >= ?", position).update_all("position = position + 1")
        update_attribute :position, position
      end
    end
  end

  after_destroy do
    collection.with_lock do
      collection.collection_items.where("position > ?", position).update_all "position = position - 1"
    end
  end

  def move_to_top
    current = self.position

    collection.with_lock do
      collection.collection_items.where("position < ? and position >= 0", current).update_all("position = position + 1")
      update_attribute :position, 0
    end
  end

  def move_to_bottom
    current = self.position
    last = collection.collection_items.maximum("position")

    collection.with_lock do
      collection.collection_items.where("position > ? and position <= ?", current, last).update_all("position = position - 1")
      update_attribute :position, last
    end
  end

  def move_to(position)
    current = self.position

    if current > position
      collection.with_lock do
        collection.collection_items.where("position >= ? and position < ?", position, current).update_all("position = position + 1")
        update_attribute :position, position
      end
    elsif current < position
      collection.with_lock do
        collection.collection_items.where("position <= ? and position > ?", position, current).update_all("position = position - 1")
        update_attribute :position, position
      end
    end
  end
end
