# == Schema Information
#
# Table name: reports
#
#  id                 :integer          not null, primary key
#  property_name      :string(255)
#  monitoring_year    :integer
#  photographer_name  :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  creator_id         :integer
#  updater_id         :integer
#  upload_progress    :string(20)
#  pdf_progress       :string(20)
#  type               :enum             default("monitoring"), not null
#  extra_signatures   :string(255)      is an Array
#  pdf                :string
#  photo_starting_num :integer          default(1), not null
#

class Report < ApplicationRecord
  TYPES = {
    "monitoring" => "Monitoring Report",
    "baseline" => "Baseline Report",
  }

  # Disable STI
  self.inheritance_column = :_type_disabled

  # Associations
  has_many :photos, -> { order(:taken_at, :image, :id) }, :dependent => :destroy, :inverse_of => :report
  accepts_nested_attributes_for :photos, :allow_destroy => true

  # Virtual attributes
  attr_accessor :upload_uuids

  # File attachments
  include PdfUploader::Attachment.new(:pdf)

  # Validations
  validates :type, :presence => true, :inclusion => { :in => TYPES.keys }
  validates :property_name, :presence => true
  validates :monitoring_year, :presence => true
  validates :photographer_name, :presence => true
  validates :photo_starting_num, :presence => true, :numericality => { :only_integer => true }
  validates :photos, :associated => true
  validate :validate_photos_presence

  # Callbacks
  before_save :clear_cached_pdf
  after_commit :handle_uploads

  def upload_uuids=(uuids)
    attribute_will_change!(:upload_uuids) if(@upload_uuids != uuids)
    @upload_uuids = uuids
  end

  def type_name
    TYPES[self.type]
  end

  def display_name
    @display_name ||= "#{self.monitoring_year} #{self.property_name}"
  end

  def photo_dates
    dates = {}
    self.photos.each_with_index do |photo, index|
      if(photo.taken_at)
        date = photo.taken_at.to_date
        dates[date] ||= []
        dates[date] << self.photo_starting_num + index
      end
    end

    dates.each do |date, photo_nums|
      dates[date] = photo_nums.first..photo_nums.last
    end

    dates
  end

  def extra_signatures=(extra)
    if(extra.present?)
      extra = extra.reject { |e| e.blank? }
    end

    super(extra)
  end

  def set_default_empty_extra_signatures!
    if(self.extra_signatures.blank?)
      write_attribute(:extra_signatures, [""])
    end
  end

  def queue_pdf_job
    self.update_column(:pdf_progress, "pending")
    ReportPdfJob.perform_later(self.id)
  rescue => e
    self.update_column(:pdf_progress, "failure")
    raise e
  end

  def generate_pdf
    pdf = Prawn::Document.new(:page_layout => :landscape, :margin => 18) do |pdf|
      photo_aspect_ratio = 4.0 / 3.0
      signature_margin = 2

      header_signature_height = 12
      header_font_size = 8
      header_padding = 8
      header_height = header_signature_height + signature_margin + (header_font_size * 2) + header_padding

      footer_signature_height = 24
      footer_font_size = 8
      footer_padding = 8
      if(self.extra_signatures.present?)
        footer_height = (footer_signature_height + signature_margin + footer_font_size) * self.extra_signatures.length
      else
        footer_height = footer_font_size + footer_padding
      end

      pdf.font "Times-Roman"
      pdf.font_size 10
      pdf.line_width = 0.5

      photo_index = 0
      self.photos.in_groups_of(6, false).each_with_index do |page_photos, page_index|
        pdf.start_new_page if(page_index > 0)

        pdf.bounding_box([0, pdf.bounds.height], :width => pdf.bounds.width, :height => header_height) do
          pdf.font_size header_font_size
          pdf.define_grid(:columns => 12, :rows => 1, :row_gutter => 0, :column_gutter => 10)

          pdf.grid([0, 0], [0, 3]).bounding_box do
            pdf.move_down header_signature_height
            pdf.stroke_horizontal_rule
            pdf.move_down signature_margin
            pdf.text "Signature of photographer", :single_line => true, :overflow => :shrink_to_fit
            pdf.text "#{self.photographer_name}, #{ENV.fetch("ORGANIZATION_NAME")}", :single_line => true, :overflow => :shrink_to_fit
          end

          pdf.grid([0, 4], [0, 5]).bounding_box do
            pdf.move_down header_signature_height
            pdf.stroke_horizontal_rule
            pdf.move_down signature_margin
            pdf.text "Date"
          end

          pdf.grid([0, 6], [0, 11]).bounding_box do
            photo_dates = self.photo_dates
            if(photo_dates.length == 1)
              pdf.text "All photos taken on #{I18n.localize(photo_dates.keys.first, :format => :short)}", :align => :right
            else
              date_texts = []
              photo_dates.each do |date, range|
                date_texts << "Photos #{range.first}-#{range.last} taken on #{I18n.localize(date, :format => :short)}"
              end
              pdf.text date_texts.join("\n"), :align => :right, :overflow => :shrink_to_fit
            end
          end
        end

        pdf.bounding_box([0, pdf.bounds.height - header_height], :width => pdf.bounds.width, :height => pdf.bounds.height - (header_height + footer_height)) do
          pdf.font_size 10

          cols = 3
          pdf.define_grid(:columns => cols, :rows => 2, :gutter => 10)
          page_photos.each_with_index do |photo, index|
            row = (index / cols.to_f).floor
            col = index % cols

            pdf.grid(row, col).bounding_box do
              if photo.image
                photo.image(:default).open do
                  pdf.image photo.image(:default).tempfile, :fit => [pdf.bounds.width, pdf.bounds.width / photo_aspect_ratio], :position => :center
                end
              end
              pdf.rectangle [0, pdf.cursor], pdf.bounds.width, 6
              pdf.fill
              pdf.move_down 1
              pdf.font("Helvetica") do
                pdf.text "#{I18n.localize(photo.taken_at, :format => :long_tz) if(photo.taken_at)} Lat=#{photo.latitude_rounded} Lon=#{photo.longitude_rounded} Alt=#{photo.altitude_feet}ft MSL WGS-84", :color => "ffffff", :size => 5, :align => :center
              end
              pdf.move_down 3
              pdf.text_box "Photo #{self.photo_starting_num + photo_index}: #{photo.caption_cleaned}", :at => [0, pdf.cursor], :width => pdf.bounds.width, :overflow => :shrink_to_fit
            end

            photo_index += 1
          end
        end
      end

      pdf.page_count.times do |i|
        pdf.go_to_page(i + 1)
        pdf.bounding_box([0, footer_height], :width => pdf.bounds.width, :height => footer_height) do
          pdf.font_size footer_font_size

          rows = 1
          property_name_column = 1
          property_name_padding = footer_padding
          if(self.extra_signatures.present?)
            rows = self.extra_signatures.length
            property_name_column = 6
            property_name_padding = footer_signature_height + signature_margin
          end
          last_row = rows - 1
          pdf.define_grid(:columns => 12, :rows => rows, :row_gutter => 0, :column_gutter => 10)

          if(self.extra_signatures.present?)
            self.extra_signatures.each_with_index do |extra_signature, row|
              pdf.grid([row, 0], [row, 3]).bounding_box do
                pdf.move_down footer_signature_height
                pdf.stroke_horizontal_rule
                pdf.move_down signature_margin
                pdf.text extra_signature, :single_line => true, :overflow => :shrink_to_fit
              end

              pdf.grid([row, 4], [row, 5]).bounding_box do
                pdf.move_down footer_signature_height
                pdf.stroke_horizontal_rule
                pdf.move_down signature_margin
                pdf.text "Date"
              end
            end
          end

          pdf.grid([last_row, property_name_column], [last_row, 10]).bounding_box do
            pdf.move_down property_name_padding
            pdf.text "<b>#{self.property_name.upcase}</b> PROPERTY #{self.monitoring_year} #{self.type.upcase} PHOTOS", :align => :center, :inline_format => true, :single_line => true, :overflow => :shrink_to_fit
          end

          pdf.grid([last_row, 11], [last_row, 11]).bounding_box do
            pdf.move_down property_name_padding
            pdf.text "#{i + 1} of #{pdf.page_count}", :align => :right
          end
        end
      end
    end

    self.pdf_attacher.attach(StringIO.new(pdf.render), metadata: {
      "filename" => "#{self.display_name}.pdf",
    })
    self.pdf_progress = nil
  end

  private

  def validate_photos_presence
    if(self.photos.blank? && self.upload_uuids.blank?)
      self.errors.add(:base, "Must upload one or more photos.")
    end
  end

  def clear_cached_pdf
    # Clear the cached PDF on any changes (except for when the PDF is actually
    # being set).
    if self.pdf_data && (self.changes.keys - ["pdf_data", "pdf_progress"]).any?
      self.pdf = nil
    end
  end

  def handle_uploads
    if(self.upload_uuids.present?)
      self.update_column(:upload_progress, "pending")
      ReportUploadsJob.perform_later(self.id, self.upload_uuids.uniq, ActiveRecord::Userstamp.config.default_stamper_class.stamper.id)
    end
  rescue => e
    self.update_column(:upload_progress, "failure")
    raise e
  end
end
