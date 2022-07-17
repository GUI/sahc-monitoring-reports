class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class_attribute :record_userstamp
  self.record_userstamp = true
  before_validation :set_updater_attribute, :if => :record_userstamp
  before_validation :set_creator_attribute, :on => :create, :if => :record_userstamp
  before_save :set_updater_attribute, :if => :record_userstamp
  before_create :set_creator_attribute, :if => :record_userstamp
  before_destroy :set_deleter_attribute, :if => :record_userstamp

  def set_creator_attribute
    return unless RequestStore.store[:current_user_email]

    if self.has_attribute?(:created_by)
      self.created_by = RequestStore.store[:current_user_email]
    end
  end

  def set_updater_attribute
    return unless RequestStore.store[:current_user_email]
    return if !new_record? && !changed?

    if self.has_attribute?(:updated_by)
      self.updated_by = RequestStore.store[:current_user_email]
    end
  end

  def set_deleter_attribute
    return unless RequestStore.store[:current_user_email]

    if self.has_attribute?(:deleted_by)
      self.deleted_by = RequestStore.store[:current_user_email]
      save
    end
  end
end
