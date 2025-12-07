# Stripe Payment Integration Setup Guide

This guide will help you set up Stripe payments for your Rails application.

## Step 1: Create a Stripe Account

1. Go to [https://stripe.com](https://stripe.com)
2. Sign up for a free account
3. Complete the account verification process

## Step 2: Get Your API Keys

1. Log in to your Stripe Dashboard: [https://dashboard.stripe.com](https://dashboard.stripe.com)
2. Click on "Developers" in the left sidebar
3. Click on "API keys"
4. You'll see two types of keys:
   - **Publishable key** (starts with `pk_test_` for test mode)
   - **Secret key** (starts with `sk_test_` for test mode)

## Step 3: Set Up Environment Variables

1. Create a `.env` file in your project root (this file is already in .gitignore):

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_your_actual_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_actual_secret_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

2. Replace the placeholder values with your actual keys from the Stripe dashboard

## Step 4: Install dotenv gem (if not already installed)

Add to your Gemfile:

```ruby
gem 'dotenv-rails', groups: [:development, :test]
```

Then run:

```bash
bundle install
```

## Step 5: Set Up Webhooks (For Production)

Webhooks allow Stripe to notify your application about payment events.

### For Local Development (using Stripe CLI):

1. Install Stripe CLI: [https://stripe.com/docs/stripe-cli](https://stripe.com/docs/stripe-cli)

2. Login to Stripe CLI:
```bash
stripe login
```

3. Forward webhooks to your local server:
```bash
stripe listen --forward-to localhost:3000/payments/webhook
```

4. The CLI will output a webhook signing secret (starts with `whsec_`). Copy this to your `.env` file as `STRIPE_WEBHOOK_SECRET`

### For Production:

1. Go to [https://dashboard.stripe.com/webhooks](https://dashboard.stripe.com/webhooks)
2. Click "Add endpoint"
3. Enter your production URL: `https://yourdomain.com/payments/webhook`
4. Select events to listen to:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
5. Copy the webhook signing secret and add it to your production environment variables

## Step 6: Test the Integration

1. Start your Rails server:
```bash
rails server
```

2. Visit the payment page:
```
http://localhost:3000/payments/new
```

3. Click "Subscribe Now" - you'll be redirected to Stripe Checkout

4. Use Stripe test card numbers:
   - **Success**: 4242 4242 4242 4242
   - **Decline**: 4000 0000 0000 0002
   - Use any future expiry date (e.g., 12/34)
   - Use any 3-digit CVC (e.g., 123)
   - Use any billing ZIP code (e.g., 12345)

## Step 7: Customize Payment Details

Edit `app/controllers/payments_controller.rb` to customize:

- **Price**: Change `unit_amount: 2999` (amount in cents, so 2999 = R$ 29.99)
- **Currency**: Change `currency: 'brl'` to your preferred currency
- **Product name and description**: Update in the `product_data` section
- **Success/Cancel URLs**: Customize redirect URLs after payment

## Available Routes

- **Payment page**: `/payments/new`
- **Create checkout**: `POST /payments/create-checkout-session`
- **Success callback**: `/payments/success`
- **Cancel callback**: `/payments/cancel`
- **Webhook endpoint**: `POST /payments/webhook`

## Security Notes

- ✓ Never commit your `.env` file to Git (it's in .gitignore)
- ✓ Never expose your secret key in client-side code
- ✓ Always use webhook signatures to verify webhook authenticity
- ✓ Use test mode keys during development
- ✓ Switch to live mode keys only when ready for production

## Going Live

When ready to accept real payments:

1. Complete Stripe account activation
2. Switch from test API keys (`pk_test_`, `sk_test_`) to live keys (`pk_live_`, `sk_live_`)
3. Update environment variables with live keys
4. Set up production webhooks
5. Test thoroughly before announcing

## Adding Premium Features to Users

To track which users have paid, you can:

1. Add a migration to add a `premium` column to users:

```bash
rails generate migration AddPremiumToUsers premium:boolean
rails db:migrate
```

2. Update the `handle_successful_payment` method in `app/controllers/payments_controller.rb`:

```ruby
def handle_successful_payment(session)
  user_id = session.metadata.user_id
  user = User.find_by(id: user_id)

  if user
    user.update(premium: true)
    Rails.logger.info "User #{user.email} upgraded to premium"
  end
end
```

3. Check premium status in your views:

```erb
<% if current_user.premium? %>
  <!-- Premium features here -->
<% end %>
```

## Support

- Stripe Documentation: [https://stripe.com/docs](https://stripe.com/docs)
- Stripe Support: [https://support.stripe.com](https://support.stripe.com)
- Test your integration: [https://stripe.com/docs/testing](https://stripe.com/docs/testing)

## Troubleshooting

### "No such customer" error
- Make sure you're using the same API keys (test/live) consistently

### Webhook signature verification fails
- Verify your webhook secret is correct in `.env`
- Make sure you're using the right secret for test/live mode

### Payment not redirecting
- Check that your success/cancel URLs are correct
- Verify your routes are properly configured

### "Invalid API Key" error
- Check that your API keys are correct in `.env`
- Ensure dotenv-rails is installed and loaded
- Restart your Rails server after changing `.env`
