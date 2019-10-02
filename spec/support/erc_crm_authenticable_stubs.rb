# frozen_string_literal: true

module ErcCrmAuthenticableStubs
  def stub_valid_request
    stub_request(:get, file_fixture("request.txt").read)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("valid_response.txt").read,
        headers: {}
      )
  end

  def stub_invalid_request_not_member
    stub_request(:get, file_fixture("request.txt").read)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("invalid_response_not_member.txt").read,
        headers: {}
      )
  end

  def stub_invalid_request_was_member
    stub_request(:get, file_fixture("request.txt").read)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("invalid_response_was_member.txt").read,
        headers: {}
      )
  end

  def stub_invalid_request_not_paying
    stub_request(:get, file_fixture("request.txt").read)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("invalid_response_not_paying.txt").read,
        headers: {}
      )
  end

  def stub_invalid_request_connection_error
    stub_request(:get, file_fixture("request.txt").read)
      .with(
        headers: headers
      ).to_return(
        status: 200,
        body: file_fixture("invalid_response_connection_error.txt").read,
        headers: {}
      )
  end

  private

  def headers
    {
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip, deflate",
      "Host" => "api.base",
      "User-Agent" => "rest-client/2.0.2 (linux-gnu x86_64) ruby/2.6.3p62"
    }
  end
end
