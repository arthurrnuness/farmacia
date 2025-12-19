class WebhooksController < ApplicationController
  # Skip CSRF token verification para webhooks do Stripe
  skip_before_action :verify_authenticity_token
  # Skip autenticação do Devise - webhooks não têm sessão de usuário
  skip_before_action :authenticate_user!, raise: false

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    # Verificar assinatura do webhook
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Webhook error: Invalid payload - #{e.message}"
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook error: Invalid signature - #{e.message}"
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Processar evento
    handle_stripe_event(event)
    render json: { message: 'success' }, status: 200
  end

  private

  def handle_stripe_event(event)
    case event.type
    when 'checkout.session.completed'
      handle_checkout_completed(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'invoice.payment_succeeded'
      handle_payment_succeeded(event.data.object)
    when 'invoice.payment_failed'
      handle_payment_failed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end
  end

  # Quando o checkout é completado
  def handle_checkout_completed(session)
    user = User.find_by(id: session.metadata.user_id)

    unless user
      Rails.logger.error "User not found for session: #{session.id}"
      return
    end

    # Atualizar usuário para premium
    user.update(
      premium: true,
      stripe_customer_id: session.customer,
      stripe_subscription_id: session.subscription
    )

    Rails.logger.info "User #{user.id} upgraded to premium (subscription: #{session.subscription})"
  end

  # Quando a assinatura é cancelada
  def handle_subscription_deleted(subscription)
    user = User.find_by(stripe_subscription_id: subscription.id)

    unless user
      Rails.logger.error "User not found for subscription: #{subscription.id}"
      return
    end

    # Remover premium do usuário
    user.update(
      premium: false,
      stripe_subscription_id: nil
    )

    Rails.logger.info "User #{user.id} subscription cancelled"

    # TODO: Enviar email notificando cancelamento
    # SubscriptionMailer.subscription_cancelled(user).deliver_later
  end

  # Quando o pagamento é bem-sucedido (renovação)
  def handle_payment_succeeded(invoice)
    customer_id = invoice.customer

    user = User.find_by(stripe_customer_id: customer_id)

    unless user
      Rails.logger.error "User not found for customer: #{customer_id}"
      return
    end

    Rails.logger.info "Payment succeeded for user #{user.id} (invoice: #{invoice.id})"

    # Garantir que o usuário está com premium ativo
    user.update(premium: true) unless user.premium?

    # TODO: Enviar email confirmando renovação
    # SubscriptionMailer.payment_succeeded(user, invoice).deliver_later
  end

  # Quando o pagamento falha
  def handle_payment_failed(invoice)
    customer_id = invoice.customer

    user = User.find_by(stripe_customer_id: customer_id)

    unless user
      Rails.logger.error "User not found for customer: #{customer_id}"
      return
    end

    Rails.logger.error "Payment failed for user #{user.id} (invoice: #{invoice.id})"

    # TODO: Enviar email notificando falha no pagamento
    # SubscriptionMailer.payment_failed(user, invoice).deliver_later
  end
end
