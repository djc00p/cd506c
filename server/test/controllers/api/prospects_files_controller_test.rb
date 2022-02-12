require "test_helper"
require "csv"

class Api::ProspectsFilesControllerTest < ActionDispatch::IntegrationTest

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
    user = users(:one)
    payload = { user_id: user.id }
    token = JWT.encode payload, ENV["AUTH_KEY"]
    headers = {
      "Content-Type": "multipart/form-data",
      "Authorization": "Bearer #{token}"
    }

    file = fixture_file_upload("test.csv", "text/csv")
    request_body = {
    	file: file,
    	email_index: "0",
    	first_name_index?: "1",
    	last_name_index?: "2",
    	force?: true,
    	has_headers?: true
    }

    response_body = { message: "Thank you! Your file is being processed now." }.to_json

    post "/api/prospects_files/import", params: request_body, headers: headers, xhr: true

    assert_equal "import", @controller.action_name
    assert_equal "multipart/form-data", @request.content_type

    pf = ProspectsFiles.order(:created_at).last
    assert pf.file.attached?
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
    user = users(:one)
    payload = { user_id: user.id }
    token = JWT.encode payload, ENV["AUTH_KEY"]
    headers1 = {
      "Content-Type": "multipart/form-data",
      "Authorization": "Bearer #{token}"
    }
    headers2 = {
      "Authorization": "Bearer #{token}"
    }
    file = fixture_file_upload("test.csv", "text/csv")
    request_body = {
      file: file,
      email_index: "0",
      first_name_index?: "1",
      last_name_index?: "2",
      force?: true,
      has_headers?: true
    }
    post "/api/prospects_files/import", params: request_body, headers: headers1, xhr: true

    assert_enqueued_jobs 1

    pf = ProspectsFiles.order(:created_at).last
    
    perform_enqueued_jobs

    response_body = {
      total: pf.row_count,
	    done: pf.done
    }.to_json

    sleep(1)

    get "/api/prospects_files/#{pf.id}/progress", headers: headers2, xhr: true

    assert_equal "progress", @controller.action_name
    assert_equal response_body, @response.body
  end
end
