class DiaryDefinition < ActiveRecord::Base
  belongs_to :hub_definition
  has_many :diaries

  validates_presence_of :external_id, :hub_definition, :order, :title

  attr_accessible :external_id, :hub_definition, :order, :position, :title

  # TODO: renomear campo order no banco e remover esse workaround
  alias_attribute :order, :position
end
