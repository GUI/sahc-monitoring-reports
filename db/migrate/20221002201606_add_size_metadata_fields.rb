class AddSizeMetadataFields < ActiveRecord::Migration[7.0]
  def change
    add_column :reports, :pdf_size, :integer, :limit => 4, :null => true
    add_column :photos, :image_derivatives_size, :integer, :limit => 4, :null => true

    Report.all.each do |report|
      report.send(:set_pdf_metadata)
      report.save!(:touch => false)
    end

    Photo.all.each do |photo|
      photo.send(:set_image_metadata)
      photo.save!(:touch => false)
    end

    change_column_null :photos, :image_derivatives_size, false
  end
end
