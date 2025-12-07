class PaymentsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def new
  end

  def create_checkout_session
    session = Stripe::Checkout::Session.create(
      customer_email: current_user.email,
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'brl',
          product_data: {
            name: 'Subscription Premium',
            description: 'Premium subscription with unlimited access'
          },
          unit_amount: 2999
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: dashboard_url + '?payment=success',
      cancel_url: payments_new_url + '?payment=cancelled',
      metadata: {
        user_id: current_user.id
      }
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    flash[:error] = "Payment error: #{e.message}"
    redirect_to payments_new_path
  end

  def success
    flash[:notice] = 'Payment successful! Thank you for your purchase.'
    redirect_to dashboard_path
  end

  def cancel
    flash[:alert] = 'Payment was cancelled.'
    redirect_to dashboard_path
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      handle_successful_payment(session)
    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      Rails.logger.info "PaymentIntent succeeded: #{payment_intent.id}"
    when 'payment_intent.payment_failed'
      payment_intent = event.data.object
      Rails.logger.error "PaymentIntent failed: #{payment_intent.id}"
    end

    render json: { message: 'success' }, status: 200
  end

  private

  def handle_successful_payment(session)
    user_id = session.metadata.user_id
    user = User.find_by(id: user_id)

    if user
      Rails.logger.info "Payment successful for user: #{user.email}"
    end
  end
end
