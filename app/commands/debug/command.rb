require 'pp'
require_relative '../base'

module SlackBot
  module Command
    class Debug < SlackBot::Command::Base

      def initialize()
      end

      def help(context:)
        user_id = /^(<.*>) */.match(context.message['event']['text'])[1]
        <<"EOS"
debug:
  debug slack event
  usage:
    #{user_id} debug
EOS
      end

      def can_handle?(context:)
        context.config.enabled_commands.find {|command| command.name == 'debug' }.debug_all_event ||
        (context.message['event']['type'] == 'app_mention' && /^<.*?> *debug/.match?(context.message['event']['text'])) ||
        (context.message['event']['channel_type'] == 'im' && /^ *debug/.match?(context.message['event']['text']))
      end

      def pass_through?(context:)
        true
      end

      def mask_secret_config(config)
        if config.is_a?(Array)
          config.map {|c| mask_secret_config(c) }
        elsif config.is_a?(Hash)
          masked_config = config.map do |k, v|
            if v.is_a?(Array) || v.is_a?(Hash)
              [k, v.map {|c| mask_secret_config(c) }]
            elsif k.start_with?('_')
              [k, '_MASKED_']
            else
              [k, v]
            end
          end
          masked_config.to_h
        else
          config
        end
      end
      private :mask_secret_config

      def handle(context:)

        if (context.message['event']['type'] == 'app_mention' && /^<.*?> *debug/.match?(context.message['event']['text'])) ||
           (context.message['event']['channel_type'] == 'im' && /^ *debug/.match?(context.message['event']['text']))

          message = <<"EOS"
config:
```#{mask_secret_config(context.config).pretty_inspect}```
commands:
```#{context.allowed_commands.keys.pretty_inspect}```
message: ```#{context.message.pretty_inspect}```
lambda_event: ```#{context.lambda_event.pretty_inspect}```
EOS
          message.gsub!(ENV['API_KEY'], "_MASKED_")
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: message, as_user: true, thread_ts:  context.message['event']['thread_ts'] || context.message['event']['ts'])

        else

          message = <<"EOS"
debug message: ```#{context.message.pretty_inspect}```
EOS
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: message, as_user: true)
        end
      end
    end
  end
end
