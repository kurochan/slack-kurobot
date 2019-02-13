require 'pp'
require 'time'
require_relative '../base'

module SlackBot
  module Command
    class Util < SlackBot::Command::Base

      COMMANDS = ['ping', 'whoami', 'user', 'channel']

      def initialize()
      end

      def help(context:)
        user_id = /^(<.*>) */.match(context.message['event']['text'])[1]
        <<"EOS"
util:
  util command
  usage:
    #{user_id} ping
    #{user_id} whoami
    #{user_id} user
    #{user_id} channel
EOS
      end

      def can_handle?(context:)

        if context.message['event']['type'] == 'app_mention'
          result = COMMANDS.find do |command|
            /^<.*?> *#{command}/.match?(context.message['event']['text'])
          end
          !result.nil?
        elsif context.message['event']['channel_type'] == 'im'
          result = COMMANDS.find do |command|
            / *#{command}/.match?(context.message['event']['text'])
          end
          !result.nil?
        else
          false
        end
      end

      def handle(context:)

        message = context.message['event']['text'].gsub(/^<.*?> */, '')
        command = /^([^ ]*) */.match(message)[1]

        case command
        when 'ping'
          ping(context)
        when 'whoami'
          whoami(context)
        when 'user'
          user(context)
        when 'channel'
          channel(context)
        else
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: "Command #{command} did not match! This might be a bug.", as_user: true)
        end
      end

      def ping(context)
        message_time = context.message['event']['ts'].to_f
        diff_seconds = Time.now.to_f - message_time

        context.client.chat_postMessage(channel: context.message['event']['channel'], text: "pong! delay: #{sprintf("%.03f", diff_seconds)} seconds", as_user: true, thread_ts: context.message['event']['thread_ts'] || context.message['event']['ts'])
      end
      private :ping

      def whoami(context)
        user = context.client.users_info(user: context.message['event']['user'])['user']
        message = {'id' => user['id'], 'real_name' => user['profile']['real_name_normalized'], 'display_name' => user['profile']['display_name_normalized']}
        context.client.chat_postMessage(channel: context.message['event']['channel'], text: "user info: ```#{message.pretty_inspect}```", as_user: true, thread_ts: context.message['event']['thread_ts'] || context.message['event']['ts'])
      end
      private :whoami

      def user(context)
        user_string = context.message['event']['text'].gsub(/^<.*?> *user */, "")
        user_id = /^<@(.*)> */.match(user_string)[1]
        begin
          user = context.client.users_info(user: user_id)['user']
          message = {'id' => user['id'], 'real_name' => user['profile']['real_name_normalized'], 'display_name' => user['profile']['display_name_normalized']}
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: "user info: ```#{message.pretty_inspect}```", as_user: true, thread_ts: context.message['event']['thread_ts'] || context.message['event']['ts'])
        rescue => e
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: "#{user_name} not found. reason: #{e.message}", as_user: true, thread_ts: context.message['event']['thread_ts'] || context.message['event']['ts'])
        end
      end
      private :user

      def channel(context)
        channel_string = context.message['event']['text'].gsub(/^<.*?> *channel */, "")
        channel_id, channel_name = /^<\#(.*)\|(.*)> */.match(channel_string).to_a.slice(1, 2)
        begin
          channel = context.client.channels_info(channel: channel_id)['channel']
          message = {'id' => channel['id'], 'name' => channel['name_normalized']}
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: "channel info: ```#{message.pretty_inspect}```", as_user: true, thread_ts: context.message['event']['thread_ts'] || context.message['event']['ts'])
        rescue => e
          context.client.chat_postMessage(channel: context.message['event']['channel'], text: "#{channel_name} not found. reason: #{e.message}", as_user: true, thread_ts: context.message['event']['thread_ts'] || context.message['event']['ts'])
        end
      end
      private :channel
    end
  end
end

