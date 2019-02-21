require_relative '../../../app/commands/base'

module SlackBot
  module Command
    class ExtSample < SlackBot::Command::Base

      def initialize()
      end

      def help(context:)
        user_id = /^(<.*>) */.match(context.message['event']['text'])[1]
        <<"EOS"
ext_sample:
  example for user side implementation
  usage:
    #{user_id} ext_sample hello world!
EOS
      end

      def can_handle?(context:)
        (context.message['event']['type'] == 'app_mention' && /^<.*?> *ext_sample /.match?(context.message['event']['text'])) ||
        (context.message['event']['channel_type'] == 'im' && /^ *ext_sample /.match?(context.message['event']['text']))
      end

      def handle(context:)
        message = context.message['event']['text'].gsub(/^.*?ext_sample */, '')
        context.client.chat_postMessage(channel: context.message['event']['channel'], text: message, as_user: true)
      end
    end
  end
end

