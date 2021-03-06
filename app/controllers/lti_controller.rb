# encoding: utf-8
class LtiController < ApplicationController
  skip_before_action :authorize_lti
  skip_before_action :get_tcc
  skip_before_action :verify_authenticity_token

  # Responsável por realizar a troca de mensagens e validação do LTI como um Tool Provider
  # De acordo com o papel informado pelo LTI Consumer, redireciona o usuário
  def establish_connection
    if authorize_lti!
      redirect_user_to_start_page
    end
  end

  def access_denied
  end

end
