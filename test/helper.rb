# frozen_string_literal: true

require 'dotenv'
Dotenv.load('.env.test')

require 'webmock'
include WebMock::API # rubocop:disable Style/MixinUsage
WebMock.enable!
WebMock.disable_net_connect!
