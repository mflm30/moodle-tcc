module Shared::Citacao
  extend ActiveSupport::Concern

  included do
    def check_for_usage
      return if self.reference.nil?
      tcc = self.reference.tcc
      tcc.chapters.each do |chapter|
        return false unless is_citation_free_to_destroy?(chapter.content)
      end
      return false unless check_content(tcc.abstract)
    end
  end

  def is_citation_free_to_destroy?(text)
    doc = Nokogiri::HTML(text)
    doc.search('citacao').each do |c|
      if (c[:id].to_i == self.id)
        errors[:base] << 'Esta referência está sendo usada em algum texto. Não é possível deletá-la.'
        return false
      end
    end
    true
  end

  def check_content(object)
    if !object.nil?
      return is_citation_free_to_destroy?(object.content)
    else
      return true
    end
  end
end