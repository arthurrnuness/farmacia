#!/bin/bash

echo "🔧 Fixing puma.rb..."

# Create clean puma config
cat > config/puma.rb << 'EOF'
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

workers ENV.fetch("WEB_CONCURRENCY") { 1 }
preload_app!
bind "tcp://0.0.0.0:3000"

plugin :tmp_restart

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
EOF

echo "✅ Created clean puma.rb"
echo "🔨 Rebuilding..."
docker-compose build web

echo "🚀 Restarting..."
docker-compose up -d web

echo "⏳ Waiting 5 seconds..."
sleep 5

echo "📝 Checking logs..."
docker-compose logs web --tail 20

echo ""
echo "🎯 Container status:"
docker-compose ps
