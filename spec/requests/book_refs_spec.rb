require 'spec_helper'

describe 'BookRef' do

  let(:attributes) { Fabricate.attributes_for(:book_ref) }
  let(:book_ref) { Fabricate(:book_ref) }

  before do
    page.set_rack_session(fake_lti_session)
  end

  context 'creates a book reference with success' do
    it '/new' do
      visit new_book_ref_path
      fill_in 'Segundo Autor', :with => attributes[:second_author]
      fill_in 'Título', :with => attributes[:title]
      click_button 'Criar Referência de Livros'
      expect(page).to have_content(:success)
    end
  end

  context 'edit a book reference with success' do
    xit '/edit' do
      visit edit_book_ref_path(book_ref.id)
      fill_in 'Segundo Autor', :with => attributes[:second_author]
      fill_in 'Título', :with => attributes[:title]
      expect(page).to have_content(:success)
    end
  end

  context 'destroy a book cap reference' do
    it '/destroy' do
      delete book_ref_path(book_ref.id)
      expect(page).to have_content(:successfully_deleted)
    end
  end

  context 'update a book cap reference' do
    it '/update' do
      put book_ref_path(book_ref.id)
      expect(page).to have_content(:success)
    end
  end

end
