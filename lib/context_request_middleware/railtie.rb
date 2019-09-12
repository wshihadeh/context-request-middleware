# frozen_string_literal: true

module ContextRequestMiddleware
  # :nodoc:
  class Railtie < Rails::Railtie
    initializer 'context_request_middleware.insert_middleware' do
      config.app_middleware.insert_after ActionDispatch::RemoteIp,
                                         ContextRequestMiddleware::Middleware
    end
  end
end
