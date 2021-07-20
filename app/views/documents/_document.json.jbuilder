json.extract! document, :id, :description, :course_id, :created_at, :updated_at
json.url document_url(document, format: :json)
