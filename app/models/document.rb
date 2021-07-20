# == Schema Information
#
# Table name: documents
#
#  id          :bigint           not null, primary key
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  course_id   :bigint           not null
#
# Indexes
#
#  index_documents_on_course_id  (course_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
class Document < ApplicationRecord
  belongs_to :course
  has_one_attached :file

  # ---- validations ---------
  validates_presence_of :description, message: "Ingrese la descripción del documento"
  validates_presence_of :file, message: "Select one document, please!"
  # ---- end validations -----
end
