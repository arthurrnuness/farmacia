class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def review
    start_date = Date.parse(params[:start_date]) rescue (Date.today - 7.days)
    end_date = Date.parse(params[:end_date]) rescue Date.today

    # Buscar todos os registros do usuário no período
    registros = Registro.joins(:habito)
                       .where(habitos: { user_id: current_user.id })
                       .where(data: start_date..end_date)
                       .order(data: :desc)
                       .includes(:habito)

    # Formatar dados para JSON
    registros_data = registros.map do |registro|
      {
        id: registro.id,
        habito_nome: registro.habito.nome,
        data: registro.data.strftime('%d/%m/%Y'),
        concluido: registro.concluido,
        observacao: registro.observacao
      }
    end

    render json: { registros: registros_data }
  end

  def export
    package = Axlsx::Package.new
    workbook = package.workbook

    # Estilo para cabeçalhos
    header_style = workbook.styles.add_style(
      bg_color: "4472C4",
      fg_color: "FFFFFF",
      b: true,
      alignment: { horizontal: :center, vertical: :center }
    )

    # Aba de Hábitos
    workbook.add_worksheet(name: "Habitos") do |sheet|
      sheet.add_row ["ID", "Nome", "Descrição", "Dias da Semana", "Frequência Semanal", "Ativo", "Tags"], style: header_style

      current_user.habitos.each do |habito|
        # Converter dias da semana de inglês para português
        dias_map = {
          "sunday" => "Dom",
          "monday" => "Seg",
          "tuesday" => "Ter",
          "wednesday" => "Qua",
          "thursday" => "Qui",
          "friday" => "Sex",
          "saturday" => "Sab"
        }

        dias_pt = habito.dias_semana.map { |dia| dias_map[dia] }.compact
        tags = habito.tags.map(&:nome).join(", ")

        sheet.add_row [
          habito.id,
          habito.nome,
          habito.descricao,
          dias_pt.join(", "),
          habito.frequencia_semanal,
          habito.ativo ? "Sim" : "Não",
          tags
        ]
      end

      sheet.column_widths 10, 30, 40, 20, 15, 10, 30
    end

    # Aba de Registros
    workbook.add_worksheet(name: "Registros") do |sheet|
      sheet.add_row ["ID", "Hábito ID", "Hábito Nome", "Data", "Concluído", "Observação"], style: header_style

      current_user.habitos.each do |habito|
        habito.registros.order(:data).each do |registro|
          sheet.add_row [
            registro.id,
            habito.id,
            habito.nome,
            registro.data.strftime("%d/%m/%Y"),
            registro.concluido ? "Sim" : "Não",
            registro.observacao
          ]
        end
      end

      sheet.column_widths 10, 10, 30, 15, 10, 50
    end

    # Aba de Tags
    workbook.add_worksheet(name: "Tags") do |sheet|
      sheet.add_row ["ID", "Nome", "Cor"], style: header_style

      current_user.tags.each do |tag|
        sheet.add_row [tag.id, tag.nome, tag.cor]
      end

      sheet.column_widths 10, 30, 15
    end

    # Aba de Relação Hábito-Tag
    workbook.add_worksheet(name: "Habitos_Tags") do |sheet|
      sheet.add_row ["Hábito ID", "Tag ID"], style: header_style

      current_user.habitos.each do |habito|
        habito.tags.each do |tag|
          sheet.add_row [habito.id, tag.id]
        end
      end

      sheet.column_widths 15, 15
    end

    # Enviar arquivo para download
    send_data package.to_stream.read,
              filename: "backup_habitos_#{Date.today.strftime('%Y%m%d')}.xlsx",
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  def import
    if params[:file].blank?
      redirect_to settings_path, alert: "Por favor, selecione um arquivo."
      return
    end

    begin
      file = params[:file]
      xlsx = Roo::Spreadsheet.open(file.path)

      ActiveRecord::Base.transaction do
        # Limpar dados existentes (CUIDADO!)
        current_user.habitos.destroy_all
        current_user.tags.destroy_all

        # Importar Tags primeiro
        tags_sheet = xlsx.sheet("Tags")
        tag_mapping = {}

        (2..tags_sheet.last_row).each do |i|
          old_id = tags_sheet.cell(i, 1).to_i
          nome = tags_sheet.cell(i, 2)
          cor = tags_sheet.cell(i, 3)

          tag = current_user.tags.create!(
            nome: nome,
            cor: cor
          )
          tag_mapping[old_id] = tag.id
        end if tags_sheet

        # Importar Hábitos
        habitos_sheet = xlsx.sheet("Habitos")
        habito_mapping = {}

        (2..habitos_sheet.last_row).each do |i|
          old_id = habitos_sheet.cell(i, 1).to_i
          nome = habitos_sheet.cell(i, 2)
          descricao = habitos_sheet.cell(i, 3)
          dias_str = habitos_sheet.cell(i, 4).to_s
          frequencia_semanal = habitos_sheet.cell(i, 5).to_i
          ativo_str = habitos_sheet.cell(i, 6).to_s

          # Parse dias da semana - converter de português para inglês
          dias_map = {
            "Dom" => "sunday",
            "Seg" => "monday",
            "Ter" => "tuesday",
            "Qua" => "wednesday",
            "Qui" => "thursday",
            "Sex" => "friday",
            "Sab" => "saturday"
          }

          dias_array = dias_str.split(",").map(&:strip)
          dias_semana_en = dias_array.map { |dia| dias_map[dia] }.compact

          habito = current_user.habitos.create!(
            nome: nome,
            descricao: descricao,
            dias_semana: dias_semana_en,
            frequencia_semanal: frequencia_semanal,
            ativo: ativo_str.downcase == "sim"
          )
          habito_mapping[old_id] = habito.id
        end

        # Importar relação Hábito-Tag
        habitos_tags_sheet = xlsx.sheet("Habitos_Tags")
        if habitos_tags_sheet
          (2..habitos_tags_sheet.last_row).each do |i|
            old_habito_id = habitos_tags_sheet.cell(i, 1).to_i
            old_tag_id = habitos_tags_sheet.cell(i, 2).to_i

            new_habito_id = habito_mapping[old_habito_id]
            new_tag_id = tag_mapping[old_tag_id]

            if new_habito_id && new_tag_id
              habito = Habito.find(new_habito_id)
              habito.tags << Tag.find(new_tag_id)
            end
          end
        end

        # Importar Registros
        registros_sheet = xlsx.sheet("Registros")
        (2..registros_sheet.last_row).each do |i|
          old_habito_id = registros_sheet.cell(i, 2).to_i
          data_str = registros_sheet.cell(i, 4).to_s
          concluido_str = registros_sheet.cell(i, 5).to_s
          observacao = registros_sheet.cell(i, 6)

          new_habito_id = habito_mapping[old_habito_id]
          next unless new_habito_id

          habito = Habito.find(new_habito_id)
          habito.registros.create!(
            data: Date.strptime(data_str, "%d/%m/%Y"),
            concluido: concluido_str.downcase == "sim",
            observacao: observacao
          )
        end
      end

      redirect_to settings_path, notice: "Backup importado com sucesso!"
    rescue => e
      redirect_to settings_path, alert: "Erro ao importar: #{e.message}"
    end
  end
end
