require 'dotenv'
Dotenv.load('.env.test')

require 'webmock'
include WebMock::API
WebMock.enable!
WebMock.disable_net_connect!
