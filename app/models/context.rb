module SlackBot
  module Model
    class Context

      attr_reader :logger, :config, :lambda_event, :lambda_context, :client, :message
      attr_accessor :allowed_commands

      def initialize(logger:, config:, lambda_event:, lambda_context:, client:, message:)
        @logger = logger
        @config = config
        @lambda_event = lambda_event
        @lambda_context = lambda_context
        @client = client
        @message = message
        @allowed_commands = []
      end
    end
  end
end
