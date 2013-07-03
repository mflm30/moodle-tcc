class Hub < ActiveRecord::Base

  belongs_to :tcc
  belongs_to :hub_definition
  has_many :diaries
  accepts_nested_attributes_for :diaries

  include TccStateMachine

  # Mass-Assignment
  attr_accessible :category, :position, :reflection, :commentary, :grade, :diaries_attributes, :hub_definition, :tcc

  validates :grade, :inclusion => { in: 0..10 }, if: :admin_evaluation_ok?

  # TODO: renomear campo category no banco e remover esse workaround
  alias_attribute :category, :position

  def comparable_versions
    versions.where(:state => %w(sent_to_admin_for_evaluation, sent_to_admin_for_revision))
  end

  def fetch_diaries(user_id)
    Moodle.fetch_hub_diaries(self, user_id)
  end

  # Verifica se possui todos os diário associados a este eixo com algum tipo de conteúdo
  def filled_diaries?
    diaries.each do |d|
      return false if d.content.blank?
    end

    true
  end

  def hub_definition=(value)
    super(value)
    build_diaries
  end

  private

  def build_diaries
    hub_definition.diary_definitions.each do |diary_definition|
      self.diaries.build(hub: self, diary_definition: diary_definition, position: diary_definition.position)
    end
  end

end
