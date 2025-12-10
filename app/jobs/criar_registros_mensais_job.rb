# app/jobs/criar_registros_mensais_job.rb
class CriarRegistrosMensaisJob < ApplicationJob
  queue_as :default
  
  def perform(mes = nil, ano = nil)
    mes ||= Date.today.next_month.month
    ano ||= Date.today.next_month.year
    
#    service = CriarRegistrosMensaisService.new(mes, ano)
 #   total = service.executar
    
    Rails.logger.info "Job concluído: #{total} registros criados para #{mes}/#{ano}"
  end
end
