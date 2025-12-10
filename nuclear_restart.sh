#!/bin/bash

echo "🧹 Complete cleanup..."
docker-compose down -v
docker rm -f rails_app rails_postgres rails_redis 2>/dev/null
docker rmi farmacia-web 2>/dev/null
docker system prune -f

echo "📝 Creating minimal puma.rb..."
cat > config/puma.rb << 'EOF'
threads 1, 5
port 3000
environment "production"
EOF

echo "🔨 Building from scratch..."
docker-compose build --no-cache web

echo "🚀 Starting..."
docker-compose up -d

echo "⏳ Waiting 20 seconds..."
sleep 20

echo "📝 Logs:"
docker-compose logs web --tail 50

echo ""
echo "🎯 Status:"
docker-compose ps
