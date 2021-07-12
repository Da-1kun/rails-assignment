class Idea < ApplicationRecord
  belongs_to :category
  validates :category_id, presence: true
  validates :body, presence: true

  scope :data, lambda {
    joins(:category).select(
      'ideas.id',
      'categories.name',
      'ideas.body',
      'ideas.created_at'
    )
  }

  scope :getByName, (lambda do |category_name|
    where(
      category_id: Category.find_by(name: category_name).id
    )
  end)
end
