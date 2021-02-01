module ActiveSnapshot
  class SnapshotItem < ActiveRecord::Base
    self.table_name = "snapshot_items"

    if defined?(ProtectedAttributes)
      attr_accessible :object, :identifier, :parent_version_id, :item_id, :item_type, :child_group_name
    end

    belongs_to :snapshot, class_name: 'ActiveSnapshot::Snapshot'
    belongs_to :item, polymorphic: true

    validates :snapshot_id, presence: true
    validates :item_id, presence: true, uniqueness: { scope: [:snapshot_id, :item_type] }
    validates :item_type, presence: true, uniqueness: { scope: [:snapshot_id, :item_id] }

    def object
      @object ||= self[:object].with_indifferent_access
    end

    def restore_item!
      ### Add any custom logic here

      if !item
        item = item_type.constantize.new
      end

      object.each do |k,v|
        item.send("#{k}=", v)
      end

      item.save!(validate: false)
    end

  end
end