require 'spec_helper'

describe Presentation do
  let!(:presentation) { Fabricate(:presentation) }

  it { respond_to :commentary, :content, :state }

  with_versioning do
    it 'should versioning' do
      old_version = presentation.versions.size
      presentation.update_attribute(:content, 'new content')
      expect(presentation.versions.size).to eq(old_version + 1)
    end
  end

  describe 'content' do
    it 'should allow empty reflection if presentation is new' do
      presentation.content = ''
      expect(presentation.new?).to be true
      expect(presentation).to be_valid
    end

    it 'should validate presence of reflection if presentation is not new' do
      presentation.content = ''
      presentation.state = 'draft'
      expect(presentation.draft?).to be true
      expect(presentation).not_to be_valid
    end
  end

  context 'email notification' do
    let(:tcc) { Fabricate.build(:tcc_with_definitions) }
    let(:presentation) { Fabricate.build(:presentation) }

    it 'should send email to orientador when state changed from draft to revision' do
      presentation.tcc = tcc
      presentation.state = 'draft'
      presentation.send_to_admin_for_revision

      expect(ActionMailer::Base.deliveries.last.to).to eq([tcc.email_orientador])
    end

    it 'should send email to orientador when state changed from draft to revision' do
      presentation.tcc = tcc
      presentation.state = 'sent_to_admin_for_revision'
      presentation.send_back_to_student

      expect(ActionMailer::Base.deliveries.last.to).to eq([tcc.email_estudante])
    end

    it 'should change states even if email is blank' do
      presentation.state = 'sent_to_admin_for_revision'
      presentation.tcc = tcc
      tcc.email_estudante = ''
      tcc.save

      presentation.send_back_to_student
      presentation.save
      expect(presentation.state).to eq('draft')
    end

    it 'should change states even if email is nil' do
      presentation.state = 'sent_to_admin_for_revision'
      presentation.tcc = tcc
      tcc.email_estudante = nil
      tcc.save

      presentation.send_back_to_student
      presentation.save
      expect(presentation.state).to eq('draft')
    end
  end
end