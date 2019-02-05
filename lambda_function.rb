require 'json'
require 'logger'
require_relative 'app/slack_bot'

def http_handler(lambda_event:, lambda_context:, logger:)
  apikey = lambda_event['queryStringParameters'] && lambda_event['queryStringParameters']['apikey']

  @slack_bot ||= SlackBot::Core.new()

  if ENV['API_KEY'] == apikey
    @slack_bot.router.handle(lambda_event: lambda_event, lambda_context: lambda_context, logger: logger)
  else
    logger.error("api key is invalid!")
    { statusCode: 400, body: 'apikey is invalid or not exist' }
  end
end

def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  @call_count ||= 0
  @call_count += 1
  logger.debug("Eevent: #{event}")
  logger.debug("CallCount: #{@call_count}")

  if event['httpMethod']
    http_handler(lambda_event: event, lambda_context: context, logger: logger)
  else
    logger.error(event.to_s)
  end
end
