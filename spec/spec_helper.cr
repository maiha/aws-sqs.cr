require "spec"
require "webmock"

Spec.before_each do
  WebMock.reset
end

def expect_http_request(method : Symbol, url : String, headers, body, return_body = "")
  WebMock.wrap do
    WebMock.stub(method, url)
      .with(headers: headers, body: body)
      .to_return(body: return_body)
    yield
  end
end

require "../src/aws-sqs"
