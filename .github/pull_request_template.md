# Description

require 'sinatra'
require 'json'

post '/payload' do
  push = JSON.parse(request.body.read)
  puts "I got some JSON: #{push.inspect}"
end
Resolves # (issue)

## How Has This Been Tested?

<!--
Please:
* describe the tests that you ran to verify your changes.
* provide instructions so we can reproduce.
-->

<!-- If valid for smoke test on feature add screenshots -->

## Due Dilligence

* [ ] Breaking change
* [ ] Requires a documentation update
