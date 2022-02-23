require "test_helper"
require "csv"

class Api::ProspectsFilesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @payload = { user_id: @user.id }
    @token = JWT.encode @payload, ENV["AUTH_KEY"]
    @headers = {
      "Content-Type": "multipart/form-data",
      "Authorization": "Bearer #{@token}"
    }

    @file = fixture_file_upload("test.csv", "text/csv")
    prospects_files(:pf1).file.attach(@file)
    @pf = prospects_files(:pf1)
  end

  test "that the import action is properly routed" do
    assert_generates "/api/prospects_files/import", controller: "api/prospects_files", action: "import"
  end

  test "a route with an HTTP method" do
    assert_routing(
      { method: 'post', path: '/api/prospects_files/import' },
      { controller: "api/prospects_files", action: "import"}
    )
  end

  test "import prospects_files and add to job queue" do
    request_body = {
    	file: fixture_file_upload("test3.csv", "text/csv"),
    	email_index: "0",
    	first_name_index?: "1",
    	last_name_index?: "2",
    	force?: true,
    	has_headers?: true
    }

    response_body = { message: "Thank you! Your file is being processed now." }.to_json

    post "/api/prospects_files/import", params: request_body, headers: @headers, xhr: true

    assert_equal "import", @controller.action_name
    assert_equal "multipart/form-data", @request.content_type

    pf = ProspectsFiles.order(:created_at).last
    assert pf.file.attached?
    assert_equal CSV.read(request_body[:file], headers: pf[:has_headers?]).count, pf[:total_rows]
    assert_enqueued_jobs 1
    assert_equal response_body, @response.body
  end

  test "that the progess action is properly routed" do
    assert_generates "/api/prospects_files/:id/progress", controller: "api/prospects_files", action: "progress" , id: ":id"
  end

  test "a route with an HTTP method GET for api/prospects_files" do
    assert_routing(
      { method: 'get', path: '/api/prospects_files/:id/progress' },
      { controller: "api/prospects_files", action: "progress", id: ":id"}
    )
  end

 test "prospects_files upload progress" do
    headers2 = {
      "Authorization": "Bearer #{@token}"
    }

    ProspectsFilesImportJob.perform_later(@pf)

    assert_enqueued_jobs 1

    perform_enqueued_jobs

    response_body = {
      total: CSV.read(@file, headers: @pf[:has_headers?]).count,
	    done: Prospect.where(user_id: @user.id, prospects_file_id: @pf.id).count
    }.to_json

    get "/api/prospects_files/#{@pf.id}/progress", headers: headers2, xhr: true

    assert_equal "progress", @controller.action_name
    assert_equal response_body, @response.body
  end
end
