# Puma configuration file

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment`
environment ENV.fetch("RAILS_ENV") { "production" }

# Specifies the number of `workers`
workers ENV.fetch("WEB_CONCURRENCY") { 0 }

# Use the `preload_app!` method when specifying a `workers` number.
if ENV.fetch("WEB_CONCURRENCY", 0).to_i > 0
  preload_app!
  
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart