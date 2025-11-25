json.extract! atividade, :id, :objetivo_id, :nome, :descricao, :frequencia_semanal, :dias_semana, :ativo, :created_at, :updated_at
json.url atividade_url(atividade, format: :json)
