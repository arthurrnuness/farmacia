# app/helpers/application_helper.rb
module ApplicationHelper
  def dia_semana_pt(dia_ingles)
    dias = {
      'monday' => 'Segunda',
      'tuesday' => 'Terça',
      'wednesday' => 'Quarta',
      'thursday' => 'Quinta',
      'friday' => 'Sexta',
      'saturday' => 'Sábado',
      'sunday' => 'Domingo'
    }
    dias[dia_ingles]
  end

  def cor_dia(percentual)
    return 'vazio' if percentual == 0
    return 'completo' if percentual == 100
    return 'parcial' if percentual >= 50
    'incompleto'
  end
end