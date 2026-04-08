class Upload < ApplicationRecord
  has_one_attached :file

  # Rails only auto-purges blobs when dependent: :purge_later (async). Using dependent: :purge
  # does not purge storage. Purge synchronously so S3/local files are removed without a worker.
  before_destroy :purge_file_from_storage

  validate :file_must_be_attached

  private

  def purge_file_from_storage
    file.purge if file.attached?
  end

  def file_must_be_attached
    errors.add(:file, "must be attached") unless file.attached?
  end
end
