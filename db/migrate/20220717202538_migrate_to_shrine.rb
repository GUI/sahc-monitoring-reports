class MigrateToShrine < ActiveRecord::Migration[7.0]
  def change
    changes = [
      {
        :model => Photo,
        :column_name => :image,
      },
      {
        :model => Upload,
        :column_name => :file,
      },
      {
        :model => Report,
        :column_name => :pdf,
      },
    ]

    changes.each do |options|
      options[:attachment_name] ||= options.fetch(:column_name)
      options[:attachment_column_name] ||= :"#{options.fetch(:attachment_name)}_data"
      add_column options.fetch(:model).table_name, options.fetch(:attachment_column_name), :jsonb
    end

    changes.each do |options|
      reversible do |dir|
        dir.up do
          model = options.fetch(:model)
          scope = model.unscoped.where("#{options.fetch(:column_name)} IS NOT NULL").order(:id)
          count = scope.count
          i = 0
          scope.find_each do |record|
            i += 1
            puts "Processing #{model} #{options.fetch(:column_name)} #{i}/#{count}"
            filename = record.read_attribute(options.fetch(:column_name))
            path = "uploads/#{record.class.to_s.underscore}/#{options.fetch(:column_name)}/#{record.id}/#{filename}"

            original_file = Tempfile.new(:binmode => true)
            connection = model.connection
            raw_connection = connection.raw_connection
            length = 1024 * 16
            connection.transaction do
              begin
                read_pos = 0
                pg_largeobject_oid = connection.select_value("SELECT pg_largeobject_oid FROM carrierwave_files WHERE path = #{connection.quote(path)}")
                lo = raw_connection.lo_open(pg_largeobject_oid)

                begin
                  raw_connection.lo_lseek(lo, read_pos, PG::SEEK_SET)
                  data = raw_connection.lo_read(lo, length)
                  read_pos = raw_connection.lo_tell(lo)
                  original_file.write(data)
                end while data
              ensure
                raw_connection.lo_close(lo) if lo
              end
            end

            if model == Photo
              original_file.close
              large = ImageProcessing::Vips
                .loader(autorot: true)
                .source(original_file)
                .convert("jpeg")
                .resize_to_limit(3000, 3000)
                .call
              original_file.unlink
              original_file = large
            end

            attacher = record.send("#{options[:attachment_name]}_attacher")
            attacher.attach(original_file, metadata: {
              "filename" => filename,
            })
            attacher.create_derivatives
            attacher.persist
          end
        end
      end
    end

    changes.each do |options|
      if options.fetch(:model) != Report
        change_column_null options.fetch(:model).table_name, options.fetch(:attachment_column_name), false
        change_column_null options.fetch(:model).table_name, options.fetch(:column_name), true
      end

      # remove_column options.fetch(:model).table_name, options.fetch(:column_name)
    end
  end
end
