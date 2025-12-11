require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get settings_index_url
    assert_response :success
  end

  test "should get export" do
    get settings_export_url
    assert_response :success
  end

  test "should get import" do
    get settings_import_url
    assert_response :success
  end
end
