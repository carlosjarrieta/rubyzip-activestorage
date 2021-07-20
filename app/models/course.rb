# == Schema Information
#
# Table name: courses
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Course < ApplicationRecord
  has_many :documents, dependent: :destroy
end
