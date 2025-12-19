class PaymentsController < ApplicationController
  # Skip autenticação global do ApplicationController para pricing
  skip_before_action :authenticate_user!, only: [:pricing]

  # Página de pricing com planos disponíveis
  def pricing
    # Página pública - acessível para todos
  end

  # Criar sessão do Stripe Checkout com plano escolhido
  def checkout
    plan = params[:plan]

    unless ['monthly', 'yearly'].include?(plan)
      flash[:error] = "Plano inválido"
      redirect_to pricing_path
      return
    end

    create_stripe_session(plan)
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error: #{e.class} - #{e.message}"
    flash[:error] = "Erro no pagamento. Tente novamente."
    redirect_to pricing_path
  rescue StandardError => e
    Rails.logger.error "Error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash[:error] = "Erro no sistema. Tente novamente."
    redirect_to pricing_path
  end

  # Retorno de pagamento bem-sucedido
  def success
    flash[:notice] = 'Pagamento realizado com sucesso! Bem-vindo ao Premium!'
    redirect_to dashboard_path
  end

  # Retorno de pagamento cancelado
  def cancel
    flash[:alert] = 'Pagamento cancelado. Você pode tentar novamente quando quiser.'
    redirect_to pricing_path
  end

  # Redirecionar para o Customer Portal do Stripe
  def portal
    # Criar sessão do Customer Portal
    session = Stripe::BillingPortal::Session.create({
      customer: current_user.stripe_customer_id,
      return_url: dashboard_url
    })

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error: #{e.class} - #{e.message}"
    flash[:error] = "Erro ao acessar portal. Tente novamente."
    redirect_to dashboard_path
  end

  private

  def create_stripe_session(plan)
    # Definir valores baseados no plano escolhido
    plan_config = if plan == 'monthly'
      { amount: 1990, interval: 'month', name: 'Premium Mensal' }
    else
      { amount: 18990, interval: 'year', name: 'Premium Anual' }
    end

    # Force binary encoding for Windows compatibility
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8

    params_hash = {
      customer_email: sanitize_string(current_user.email),
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'brl',
          product_data: {
            name: sanitize_string(plan_config[:name]),
            description: sanitize_string("Assinatura #{plan_config[:name]} - Hábitos ilimitados e recursos avançados")
          },
          unit_amount: plan_config[:amount],
          recurring: {
            interval: plan_config[:interval]
          }
        },
        quantity: 1
      }],
      mode: 'subscription',
      success_url: sanitize_string(payments_success_url),
      cancel_url: sanitize_string(payments_cancel_url),
      metadata: {
        user_id: current_user.id.to_s,
        plan: plan
      }
    }

    session = Stripe::Checkout::Session.create(params_hash)
    redirect_to session.url, allow_other_host: true
  end

  def sanitize_string(str)
    str.to_s.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end
end
