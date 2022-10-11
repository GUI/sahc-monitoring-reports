module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_s
    when "success"
      "alert-success"
    when "error"
      "alert-danger"
    when "alert"
      "alert-warning"
    when "notice"
      "alert-info"
    else
      "alert-#{flash_type}"
    end
  end

  def file_storage_size
    @file_storage_size ||= ActiveRecord::Base.connection.select_value <<~SQL
      SELECT SUM(size)
      FROM (
        SELECT SUM(image_size) + SUM(image_derivatives_size) AS size
        FROM photos
        UNION ALL
        SELECT SUM(pdf_size) AS size
        FROM reports
        UNION ALL
        SELECT SUM(file_size) AS size
        FROM uploads
      ) AS t
    SQL
  end

  def file_storage_size_limit
    10737418240
  end

  def file_storage_size_percent
    @file_storage_size_percent ||= ((file_storage_size / file_storage_size_limit.to_f) * 100).round
  end
end
