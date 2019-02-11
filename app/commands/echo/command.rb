require_relative '../base'

module SlackBot
  module Command
    class Echo < SlackBot::Command::Base

      def initialize()
      end

      def can_handle?(context:)
        (context.message['event']['type'] == 'app_mention' && /^<.*?> *echo /.match?(context.message['event']['text'])) ||
        (context.message['event']['channel_type'] == 'im' && /^ *echo /.match?(context.message['event']['text']))
      end

      def handle(context:)
        message = context.message['event']['text'].gsub(/^.*echo */, '')
        context.client.chat_postMessage(channel: context.message['event']['channel'], text: message, as_user: true)
      end
    end
  end
end

