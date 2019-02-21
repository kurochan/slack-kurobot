module SlackBot
  module Model
    class Context

      attr_reader :logger, :config, :lambda_event, :lambda_context, :dynamodb, :client, :message
      attr_accessor :allowed_commands, :command_config

      def initialize(logger:, config:, lambda_event:, lambda_context:, dynamodb:, client:, message:, allowed_commands: nil, command_config: nil)
        @logger = logger
        @config = config
        @lambda_event = lambda_event
        @lambda_context = lambda_context
        @dynamodb = dynamodb
        @client = client
        @message = message
        @allowed_commands = allowed_commands
        @command_config = command_config
      end
    end
  end
end
