module SlackBot
  module Model
    class Context

      attr_reader :logger, :config, :lambda_event, :lambda_context, :dynamodb, :client, :message
      attr_accessor :allowed_commands

      def initialize(logger:, config:, lambda_event:, lambda_context:, dynamodb:, client:, message:)
        @logger = logger
        @config = config
        @lambda_event = lambda_event
        @lambda_context = lambda_context
        @dynamodb = dynamodb
        @client = client
        @message = message
        @allowed_commands = []
      end
    end
  end
end
