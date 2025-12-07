# Monkey patch to fix Stripe gem Windows encoding bug
# This addresses an issue where Stripe's uname detection fails on Windows
# See: https://github.com/stripe/stripe-ruby/issues/

module Stripe
  class APIRequestor
    class SystemProfiler
      class << self
        def uname_from_system_ver
          # Force UTF-8 encoding for Windows compatibility
          version = `ver 2>&1`.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
          version.strip
        rescue => e
          Rails.logger.warn "Stripe: Could not get system version - #{e.message}"
          "unknown"
        end

        def uname
          # Override to handle Windows encoding issues
          if RUBY_PLATFORM =~ /win32|mingw32|mingw|cygwin|mswin/
            {
              machine: RbConfig::CONFIG['host_cpu'] || 'unknown',
              sysname: 'Windows',
              version: uname_from_system_ver,
              release: 'unknown'
            }
          else
            # Original implementation for non-Windows
            uname_str = `uname -a 2>/dev/null`.strip
            uname_str = uname_str.empty? ? uname_from_system : uname_str
            {
              machine: RbConfig::CONFIG['host_cpu'],
              sysname: uname_str,
              version: 'unknown',
              release: 'unknown'
            }
          end
        rescue => e
          Rails.logger.warn "Stripe: Could not get uname - #{e.message}"
          {
            machine: 'unknown',
            sysname: 'unknown',
            version: 'unknown',
            release: 'unknown'
          }
        end
      end
    end
  end
end
