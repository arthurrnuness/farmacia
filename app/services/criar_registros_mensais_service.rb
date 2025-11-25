# app/services/criar_registros_mensais_service.rb
class CriarRegistrosMensaisService
  def initialize(mes = Date.today.month, ano = Date.today.year)
    @mes = mes
    @ano = ano
    @primeiro_dia = Date.new(@ano, @mes, 1)
    @ultimo_dia = @primeiro_dia.end_of_month
  end
  
  def executar
    Rails.logger.info "Criando registros para #{@mes}/#{@ano}"
    
    total_criados = 0
    
    Atividade.where(ativo: true).find_each do |atividade|
      criados = criar_registros_para_atividade(atividade)
      total_criados += criados
    end
    
    Rails.logger.info "Total de registros criados: #{total_criados}"
    total_criados
  end
  
  private
  
  def criar_registros_para_atividade(atividade)
    criados = 0
    
    (@primeiro_dia..@ultimo_dia).each do |dia|
      # Verificar se deve fazer neste dia
      next unless atividade.fazer_hoje?(dia)
      
      # Criar registro apenas se não existir
      unless Registro.exists?(atividade_id: atividade.id, data: dia)
        Registro.create!(
          atividade: atividade,
          data: dia,
          concluido: false,
          observacao: nil
        )
        criados += 1
      end
    end
    
    Rails.logger.info "Atividade '#{atividade.nome}': #{criados} registros criados"
    criados
  end
end