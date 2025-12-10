# config/initializers/scheduler.rb
require 'rufus-scheduler'

return if defined?(Rails::Console) || Rails.env.test?

scheduler = Rufus::Scheduler.new

# Teste: executa a cada 2 minutos
scheduler.every '2h' do
  Rails.logger.info "Executando MensagemDiariaJob - #{Time.now}"
  MensagemDiariaJob.perform_now
end

# Todo dia 1º às 00:01 (cria registros do mês atual)
#scheduler.cron '1 0 1 * *' do
#  Rails.logger.info "Iniciando criação de registros mensais - #{Time.now}"
#  CriarRegistrosMensaisJob.perform_later
#end

# Também cria registros ao subir servidor (caso tenha esquecido)
#scheduler.in '30s' do
#  Rails.logger.info "Verificando registros pendentes - #{Time.now}"
#  CriarRegistrosMensaisJob.perform_later(Date.today.month, Date.today.year)
