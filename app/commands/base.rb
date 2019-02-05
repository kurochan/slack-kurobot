module SlackBot
  module Command
    class Base

      def initialize()
      end

      def can_handle?(context:)

        context.logger.warn("#{self.class.name}#can_handle?: This command is NOT implemented!")
        false
      end

      def pass_through?(context:)
        false
      end

      def handle(context:)
        context.logger.warn("#{self.class.name}#handle: This command is NOT implemented!")
      end
    end
  end
end

