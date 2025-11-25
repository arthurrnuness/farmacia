json.extract! registro, :id, :atividade_id, :data, :concluido, :observacao, :created_at, :updated_at
json.url registro_url(registro, format: :json)
