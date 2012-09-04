class EventImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # URL for "no image available" image
  def default_url
    "/assets/no_event_image.png"
  end

  # Resize all images to 500 x 500
  process :resize_to_fit => [500, 500]

  # Create 200 x 200 thumbanil version of all images
  version :thumb do
    process resize_to_fill: [200, 200]
  end

  # Only allow images with certain extensions to be uploaded
  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
