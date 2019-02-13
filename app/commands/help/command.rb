require_relative '../base'

module SlackBot
  module Command
    class Help < SlackBot::Command::Base

      def initialize()
      end

      def help(context:)
        user_id = /^(<.*>) */.match(context.message['event']['text'])[1]
        <<"EOS"
help:
  this message
  usage:
    #{user_id} help
EOS
      end

      def can_handle?(context:)
        (context.message['event']['type'] == 'app_mention' && /^<.*?> *help/.match?(context.message['event']['text'])) ||
        (context.message['event']['channel_type'] == 'im' && /^ *help/.match?(context.message['event']['text']))
      end

      def handle(context:)
        helps = context.allowed_commands.map {|name, command| command.help(context: context) }
        message = "```#{helps.join("\n")}```"
        context.client.chat_postMessage(channel: context.message['event']['channel'], text: message, as_user: true)
      end
    end
  end
end

