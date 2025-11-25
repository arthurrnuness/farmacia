# config/initializers/scheduler.rb
require 'rufus-scheduler'

return if defined?(Rails::Console) || Rails.env.test?

scheduler = Rufus::Scheduler.new

# Todo dia às 8h
#scheduler.every '30m' do
#  MensagemDiariaJob.perform_later
#end

# Todo dia 1º às 00:01 (cria registros do mês atual)
scheduler.cron '1 0 1 * *' do
  Rails.logger.info "Iniciando criação de registros mensais - #{Time.now}"
  CriarRegistrosMensaisJob.perform_later
end

# Também cria registros ao subir servidor (caso tenha esquecido)
scheduler.in '30s' do
  Rails.logger.info "Verificando registros pendentes - #{Time.now}"
  CriarRegistrosMensaisJob.perform_later(Date.today.month, Date.today.year)
end