require 'pp'
require 'yaml'
require 'hashie'

module SlackBot
  module Command
    class Router

      COMMAND_RELATIVE_PATH = '../commands'

      @@commands = nil

      def initialize(commands: nil)
        @@commands ||= commands || init_commands
      end

      def handle(context:)

        context.logger.debug("Message: #{context.message}")

        return nil if context.message['authed_users'].include?(context.message['event']['user'])

        allowed_commands = get_allowed_command_configs(context).map do |config|
          [config.name, @@commands[config.name]]
        end
        context.allowed_commands = allowed_commands.to_h
        context.logger.debug("AllowedCommands: #{context.allowed_commands.keys}")

        context.allowed_commands.each do |name, command|
          if command.can_handle?(context: context)
            command.handle(context: context)
            break unless command.pass_through?(context: context)
          end
        end
      end

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

      def init_commands
        command_base_path = File.expand_path(COMMAND_RELATIVE_PATH, __FILE__)
        command_paths = Dir.glob("#{command_base_path}/*/")
        commands = command_paths.map do |path|
          if File.exists?("#{path}/command.rb")
            require_relative "#{path}/command"
            command_name = File.basename(path)
            [command_name, Object.const_get("SlackBot::Command::#{command_name.capitalize}").new]
          else
            nil
          end
        end
        commands.select {|c| !c.nil? }.to_h
      end
      private :init_commands
    end
  end
end
