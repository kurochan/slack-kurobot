require 'hashie'
require 'slack-ruby-client'
require_relative 'models/context'
require_relative 'command_router'

module SlackBot
  class Router

    CONFIG_RELATIVE_PATH = '../../conf/config.yml'

    def initialize(command_router: nil)
      @command_router = command_router || SlackBot::Command::Router.new
      config_path = File.expand_path(CONFIG_RELATIVE_PATH, __FILE__)
      @config_all = Hashie::Mash.load(config_path)
    end

    def handle(lambda_event:, lambda_context:, logger:)

      body = JSON.parse(lambda_event['body'])

      config = @config_all.team_config.find {|config| config.team_id == body['team_id'] }

      client = Slack::Web::Client.new(token: config._slack_access_token)

      context = SlackBot::Model::Context.new(logger: logger, config: config, lambda_event: lambda_event, lambda_context: lambda_context, client: client, message: body)

      logger.debug("Type: #{body['type']}")
      logger.debug("Body: #{body}")

      case body['type']
      when 'url_verification'
        { statusCode: 200, body: body['challenge'] }

      when 'event_callback'
        @command_router.handle(context: context)
        { statusCode: 200, body: 'OK' }
      else
        logger.error("unknown_type")
        { statusCode: 200, body: 'OK' }
      end
    end
  end
end
