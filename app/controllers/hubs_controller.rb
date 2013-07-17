# encoding: utf-8
class HubsController < ApplicationController

  include LtiTccFilters

  def show
    @current_user = current_user
    set_tab ('hub'+params[:position]).to_sym

    @hub = @tcc.hubs.find_by_position(params[:position])

    last_comment_version = @hub.versions.where('state != ?', 'draft').last

    @last_hub_commented = last_comment_version.reify unless last_comment_version.nil?

    # Busca diários no moodle
    @hub.fetch_diaries(@user_id)
  end

  def save
    @tcc = Tcc.find_by_moodle_user(@user_id)
    new_state = params[:hub][:new_state]

    @hub = @tcc.hubs.find_by_position(params[:hub][:position])
    @hub.attributes = params[:hub]

    #
    # Estudante
    #
    if current_user.student?

      if @hub.valid?
        case new_state
          when 'revision'
            @hub.send_to_admin_for_revision if @hub.may_send_to_admin_for_revision?
          when 'evaluation'
            @hub.send_to_admin_for_evaluation if @hub.may_send_to_admin_for_evaluation?
        end

        @hub.save
        flash[:success] = t(:successfully_saved)
        return redirect_to show_hubs_path
      end
    else


      #
      # TUTOR
      #

      # Ação do botão
      old_state = @hub.state

      if params[:valued]
        @hub.admin_evaluate_ok if @hub.may_admin_evaluate_ok?
      else
        @hub.send_back_to_student if @hub.may_send_back_to_student?
      end

      if @hub.valid? && @hub.save
        return redirect_to show_hubs_path(:position => @hub.position, :moodle_user => @user_id)

      else
        @hub.state = old_state
      end
    end

    render :show
  end

  def update_state
    if params[:post][:state] == 'admin_evaluation_ok' && @hub.grade.nil?
      flash[:error] = 'Não é possível alterar para este estado sem ter dado uma nota.'
      return redirect_to instructor_admin_tccs_path
    end
    @hub.state = params[:post][:state].downcase.underscore
    @hub.save!
    flash[:success] = t(:successfully_saved)
    return redirect_to instructor_admin_tccs_path
  end
end
