# encoding: utf-8
class ChaptersController < ApplicationController

  def edit
    set_tab ('chapter'+params[:position]).to_sym

    authorize(@tcc)
    @chapter = @tcc.chapters.find_by(position: params[:position])
    if must_import?(@chapter)
      if policy(@tcc).import_chapters?
        redirect_to import_chapters_path(params[:moodle_user], params[:position])
      else
        redirect_to empty_chapters_path(params[:moodle_user], params[:position])
      end
    end
  end

  def save
    authorize(@tcc)

    @chapter = @tcc.chapters.find_by(position: params[:position])
    @chapter.attributes = params[:chapter]
    if @chapter.valid? && @chapter.save
      flash[:success] = t(:successfully_saved)
      return redirect_to edit_chapters_path(position: @chapter.position.to_s)
    end

    # falhou, precisamos re-exibir as informações
    set_tab ('chapter'+params[:position]).to_sym
    render :edit
  end

  def empty
    authorize(@tcc, :show?)
    set_tab ('chapter'+params[:position]).to_sym
  end

  def import
    set_tab ('chapter'+params[:position]).to_sym
    @chapter = @tcc.chapters.find_by(position: params[:position])

    @can_import = can_import?(@chapter)
    flash[:alert] = t('chapter_import_cannot_proceed') unless must_import?(@chapter)
  end

  def execute_import
    authorize(@tcc, :import_chapters?)
    set_tab ('chapter'+params[:position]).to_sym
    @chapter = @tcc.chapters.find_by(position: params[:position])

    redirect_to edit_chapters_path(params[:moodle_user], params[:position]), alert: t('chapter_import_cannot_proceed') unless can_import?(@chapter)

    remote = MoodleAPI::MoodleOnlineText.new

    @chapter.content = remote.fetch_online_text(current_moodle_user, @chapter.chapter_definition.coursemodule_id)
    @chapter.save!

    redirect_to edit_chapters_path(params[:moodle_user], params[:position]), notice: t('chapter_import_successfully')
  end

  private

  # FIXME: criar policy para chapter e as duas opções abaixo devem ir para lá
  # FIXME: no chapter_policy mapear para policy_tcc
  def must_import?(chapter)
    chapter.empty? && chapter.chapter_definition.remote_text?
  end

  def can_import?(chapter)
    authorize(@tcc, :import_chapters?)
    # As seguintes condições precisam ser preenchidas para que o texto possa ser importado:
    # - O conteúdo do capítulo precisa estar vazio ou em branco
    # - O chapter_definition precisa ter uma referência para uma atividade remota (coursemodule_id)
    # - O status do envio dessa atividade remota tem que estar marcada como "submitted"
    if chapter.empty? && chapter.chapter_definition.remote_text?
      remote = MoodleAPI::MoodleOnlineText.new
      status = remote.fetch_online_text_status(current_moodle_user, chapter.chapter_definition.coursemodule_id)

      return (status == 'submitted')
    end

    false
  end
end
