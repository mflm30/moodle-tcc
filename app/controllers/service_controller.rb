# encoding: utf-8
class ServiceController < ApplicationController
  skip_before_action :authorize_lti
  skip_before_action :get_tcc
  skip_before_action :verify_authenticity_token # Prevents CSRF warning
  before_action :check_consumer_key

  def report_tcc
    # Envia TCCs
    if params[:user_ids]

      @tccs = Tcc.joins(:student).where(['people.moodle_id IN(?)', params[:user_ids]]).includes(:abstract, :chapters, :student)
      @tccs = TccDecorator.decorate_collection(@tccs.all)
      render 'service/report_tcc', status: :ok
    else
      render status: :bad_request, json: {error_message: 'Invalid params (missing user_ids)'}
    end
  end

  def tcc_definition
    if params[:tcc_definition_id]
      @tcc_definition = TccDefinition.where(id: params[:tcc_definition_id]).includes(:chapter_definitions).first
      render 'service/tcc_definition', status: :ok
    else
      render status: :bad_request, json: {error_message: 'Invalid params (missing tcc_definition_id)'}
    end
  end

  def ping
    render text: 'Ok', status: :ok
  end

  private

  def check_consumer_key
    if params[:consumer_key] != Settings.consumer_key
      Rails.logger.debug "[WS Relatórios]: Falha na autenticação. #{params.inspect}"
      render status: :unauthorized, json: {error_message: 'Invalid consumer key'}
    end
  end
end
