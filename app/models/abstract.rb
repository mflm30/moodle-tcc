class Abstract < ActiveRecord::Base
  belongs_to :tcc
  attr_accessible :commentary, :content_pt, :key_words_pt

  has_paper_trail meta: {state: :state}

  include TccStateMachine

end
