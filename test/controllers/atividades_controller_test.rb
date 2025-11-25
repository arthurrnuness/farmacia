require "test_helper"

class AtividadesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @atividade = atividades(:one)
  end

  test "should get index" do
    get atividades_url
    assert_response :success
  end

  test "should get new" do
    get new_atividade_url
    assert_response :success
  end

  test "should create atividade" do
    assert_difference("Atividade.count") do
      post atividades_url, params: { atividade: { ativo: @atividade.ativo, descricao: @atividade.descricao, dias_semana: @atividade.dias_semana, frequencia_semanal: @atividade.frequencia_semanal, nome: @atividade.nome, objetivo_id: @atividade.objetivo_id } }
    end

    assert_redirected_to atividade_url(Atividade.last)
  end

  test "should show atividade" do
    get atividade_url(@atividade)
    assert_response :success
  end

  test "should get edit" do
    get edit_atividade_url(@atividade)
    assert_response :success
  end

  test "should update atividade" do
    patch atividade_url(@atividade), params: { atividade: { ativo: @atividade.ativo, descricao: @atividade.descricao, dias_semana: @atividade.dias_semana, frequencia_semanal: @atividade.frequencia_semanal, nome: @atividade.nome, objetivo_id: @atividade.objetivo_id } }
    assert_redirected_to atividade_url(@atividade)
  end

  test "should destroy atividade" do
    assert_difference("Atividade.count", -1) do
      delete atividade_url(@atividade)
    end

    assert_redirected_to atividades_url
  end
end
