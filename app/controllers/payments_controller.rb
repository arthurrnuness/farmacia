class PaymentsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def new
  end

  def create_checkout_session
    create_stripe_session
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error: #{e.class} - #{e.message}"
    flash[:error] = "Payment error"
    redirect_to payments_new_path
  rescue StandardError => e
    Rails.logger.error "Error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash[:error] = "System error"
    redirect_to payments_new_path
  end

  def success
    flash[:notice] = 'Payment successful'
    redirect_to dashboard_path
  end

  def cancel
    flash[:alert] = 'Payment cancelled'
    redirect_to dashboard_path
  end

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      render json: { error: 'Invalid' }, status: 400
      return
    end

    handle_stripe_event(event)
    render json: { message: 'success' }, status: 200
  end

  private

  def create_stripe_session
    # Force binary encoding for Windows compatibility
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8

    params_hash = {
      customer_email: sanitize_string(current_user.email),
      payment_method_types: ['card'],
      line_items: build_line_items,
      mode: 'payment',
      success_url: sanitize_string(build_success_url),
      cancel_url: sanitize_string(build_cancel_url),
      metadata: { user_id: current_user.id.to_s }
    }

    session = Stripe::Checkout::Session.create(params_hash)
    redirect_to session.url, allow_other_host: true
  end

  def sanitize_string(str)
    str.to_s.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end

  def build_line_items
    [{
      price_data: {
        currency: 'brl',
        product_data: {
          name: 'Premium'.encode('UTF-8'),
          description: 'Premium subscription'.encode('UTF-8')
        },
        unit_amount: 2999
      },
      quantity: 1
    }]
  end

  def build_success_url
    url = dashboard_url
    "#{url}?payment=success"
  end

  def build_cancel_url
    url = payments_new_url
    "#{url}?payment=cancelled"
  end

  def handle_stripe_event(event)
    case event.type
    when 'checkout.session.completed'
      handle_successful_payment(event.data.object)
    when 'payment_intent.succeeded'
      Rails.logger.info "Payment succeeded"
    when 'payment_intent.payment_failed'
      Rails.logger.error "Payment failed"
    end
  end

  def handle_successful_payment(session)
    user = User.find_by(id: session.metadata.user_id)
    Rails.logger.info "Payment successful for user ID: #{user.id}" if user
  end
end
