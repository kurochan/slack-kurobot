require 'pp'
require 'time'
require 'yaml'
require 'hashie'

module SlackBot
  module Command
    class Router

      COMMAND_RELATIVE_PATHS = ['../commands', '../../ext/commands']

      @@commands = nil

      def initialize(commands: nil)
        @@commands ||= commands || COMMAND_RELATIVE_PATHS.map {|path| init_commands(path) }.inject({}){|a, b| a.merge(b) }
      end

      def handle(context:)

        context.logger.debug("message: #{context.message}")

        return nil unless validate_message(context)
        accept_message(context)

        allowed_commands = get_allowed_command_configs(context).map do |config|
          [config.name, @@commands[config.name]]
        end
        context.allowed_commands = allowed_commands.to_h
        context.logger.debug("AllowedCommands: #{context.allowed_commands.keys}")

        context.allowed_commands.each do |name, command|
          context.command_config = context.config.enabled_commands.find {|command| command.name == name }
          if command.can_handle?(context: context)
            context.logger.debug("handle: #{name}")
            command.handle(context: context)
            break unless command.pass_through?(context: context)
          end
        end
      end

      def item_key_prefix(context)
        "#{context.message['team_id']}:#{context.message['event']['channel']}:#{context.message['event']['ts']}:#{context.message['event']['type']}"
      end
      private :item_key_prefix

      def validate_message(context)
        return false if context.message['authed_users'].include?(context.message['event']['user']) ||
                        context.message['event']['user'].nil? ||
                        context.message['event']['user'].empty?

        item = context.dynamodb.get_item(key: {'item_key' => "#{item_key_prefix(context)}:accept"})[:item]
        if item
          context.logger.warn("duplicate message detected (maybe timeout): #{item}")
          return false
        end

        true
      end
      private :validate_message

      def accept_message(context)
        now = Time.now
        expire_at = now.to_i + 600
        item = {
          'item_key' => "#{item_key_prefix(context)}:accept",
          'created_at' => now.to_s,
          'ttl' => expire_at
        }
        context.dynamodb.put_item(item: item)
      end
      private :accept_message

      def get_allowed_command_configs(context)
        commands = context.config.enabled_commands.map do |command|
          if (command.allowed_user.nil? || scommand.allowed_users.include?('all') || command.allowed_users.include?(context.message['event']['user'])) &&
             (command.allowed_channels.nil? || command.allowed_channels.include?('all') || command.allowed_channels.include?(context.message['event']['channel'])) &&
             (command.denied_users.nil? || !command.denied_users.include?('all') || !command.denied_users.include?(context.message['event']['user'])) &&
             (command.denied_channels.nil? || !command.denied_channels.include?('all') || !command.denied_channels.include?(context.message['event']['channel']))
            command
          else
            nil
          end
        end
        commands.select {|c| !c.nil? }
      end
      private :get_allowed_command_configs

      def init_commands(base_path)
        command_base_path = File.expand_path(base_path, __FILE__)
        command_paths = Dir.glob("#{command_base_path}/*/")
        commands = command_paths.map do |path|
          if File.exists?("#{path}/command.rb")
            require_relative "#{path}/command"
            command_name = File.basename(path)
            [command_name, Object.const_get("SlackBot::Command::#{to_camel(command_name)}").new]
          else
            nil
          end
        end
        commands.select {|c| !c.nil? }.to_h
      end
      private :init_commands

      def to_camel(str)
        str.split("_").map{|w| w[0] = w[0].upcase; w}.join
      end
      private :to_camel
    end
  end
end
