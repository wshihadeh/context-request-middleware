# frozen_string_literal: true

require 'context_request_middleware/context'

module ContextRequestMiddleware
  module Context
    # Class for retrieving the session if set via rack cookie.
    # This requires the session and more data to be stored in
    # '_session_id' cookie key.
    class CookieSessionRetriever
      include ActiveSupport::Configurable

      HTTP_HEADER = 'Set-Cookie'

      attr_accessor :data

      def initialize(request)
        @request = request
        @data = {}
      end

      def call(status, header, body)
        @response = Rack::Response.new(body, status, header)
        if new_session_id?
          data[:context_id] = session_id
          data[:owner_id] = owner_id
          data[:context_status] = context_status
          data[:context_type] = context_type
          data[:app_id] = ContextRequestMiddleware.app_id
        end
        data
      end

      private

      def owner_id
        from_env('cookie_session.user_id', 'unknown')
      end

      def context_status
        'unknown'
      end

      def context_type
        'session_cookie'
      end

      def new_session_id?
        session_id && session_id != req_cookie_session_id
      end

      def session_id
        @session_id ||= set_cookie_header &&
                        set_cookie_header.match(/_session_id=([^\;]+)/)[1]
      end

      def req_cookie_session_id
        Rack::Utils.parse_cookies(@request.env)['_session_id'] ||
          (@request.env['action_dispatch.cookies'] || {})['_session_id']
      end

      def set_cookie_header
        @response.headers.fetch(HTTP_HEADER, nil)
      end

      def from_env(key, default = nil)
        @request.env.fetch(key, default)
      end
    end
  end
end
