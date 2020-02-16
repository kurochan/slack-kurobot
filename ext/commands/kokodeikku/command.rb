require_relative '../../../app/commands/base'

ENV['MECAB_PATH'] = '/var/task/mecab/lib/libmecab.so'
require 'ikku'

module SlackBot
  module Command
    class Kokodeikku < SlackBot::Command::Base

      def initialize()
        @reviewer = Ikku::Reviewer.new
      end

      def help(context:)
        <<"EOS"
kokodeikku:
  detect haiku from text
  usage:
    古池や蛙飛び込む水の音
EOS
      end

      def can_handle?(context:)
        not @reviewer.find(context.message['event']['text']).nil?
      end

      def pass_through?(context:)
        true
      end

      def handle(context:)
        song = @reviewer.find(context.message['event']['text'])
        ikku = song.phrases.map { |a| a.join }.join(' ')
        message = ":memo: ここで一句 「#{ikku}」:clap:"
        thread_ts = context.message['event']['thread_ts']
        if (thread_ts)
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: message, as_user: true, thread_ts: thread_ts)
        else
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: message, as_user: true)
        end
      end
    end
  end
end

