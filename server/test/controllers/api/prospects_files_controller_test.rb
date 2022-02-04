require "test_helper"

class Api::ProspectsFilesControllerTest < ActionDispatch::IntegrationTest
#   Method: POST
# Path: /api/prospects_files/import
# Header: {
# 	"Content-Type": "multipart/form-data"
# 	, …
# }
# Request Body: {
# 	file: FILE,
# 	email_index: number,
# 	first_name_index?: number,
# 	last_name_index?: number,
# 	force?: boolean,
# 	has_headers?: boolean
# }
# Overwrite existing prospects if “force” parameter is true.
# Skip the first row if “has_headers” parameter is true.
# Response Body: depends if solution is synchronous or asynchronous

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
end
