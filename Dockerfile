FROM ruby:3.2.2-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips \
    nodejs \
    npm \
    postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Copy Gemfiles
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Precompile assets (will use dummy SECRET_KEY_BASE)
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile || true

# Expose port
EXPOSE 3000

# Entrypoint
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Start server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
