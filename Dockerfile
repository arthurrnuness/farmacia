# Dockerfile
FROM ruby:3.2.2-slim

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Copy Gemfile
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Precompile assets (for production)
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Expose port
EXPOSE 3000

# Start server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]