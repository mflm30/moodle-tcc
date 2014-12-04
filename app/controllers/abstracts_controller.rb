# encoding: utf-8
class AbstractsController < ApplicationController
  def edit
    set_tab :abstract
    @abstract = @tcc.abstract || @tcc.build_abstract

    authorize @abstract

    @comment = @tcc.abstract.comment || @tcc.abstract.build_comment
  end

  def create
    @abstract = @tcc.build_abstract(params[:abstract])

    authorize @abstract

    @comment = @tcc.abstract.build_comment(params[:chapter_comment])

    change_state

    if @abstract.valid? && @abstract.save
      @comment.save!
      flash[:success] = t(:successfully_saved)
      redirect_to edit_abstracts_path(moodle_user: params[:moodle_user])
    else
      set_tab :abstract
      render :edit
    end
  end

  def update
    @abstract = @tcc.abstract

    authorize @abstract

    @abstract.attributes=params[:abstract]
    @comment = @tcc.abstract.comment || @tcc.abstract.build_comment
    @comment.attributes = params[:chapter_comment]

    change_state

    if @abstract.valid? && @abstract.save
      @comment.save!
      flash[:success] = t(:successfully_saved)
      redirect_to edit_abstracts_path(moodle_user: params[:moodle_user])
    else
      set_tab :abstract
      render :edit
    end
  end

  private

  def change_state
    if params[:done]
      @abstract.to_done
    elsif params[:review]
      @abstract.to_review
    elsif params[:draft]
      @abstract.to_draft
    end
  end
end
