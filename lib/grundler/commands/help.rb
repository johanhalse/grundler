module Grundler
  module Commands
    class Help
      def initialize(_cli, _arguments, _json_writer)
        puts Help.help_text
      end

      def self.help_text
        <<~HELP_TEXT

          Usage: grundle <command>

          grundle add      add package to project
          grundle install  install all packages in lockfile
          grundle update   update all packages in lockfile
          grundle remove   remove a package from project
          grundle help     display this help

        HELP_TEXT
      end
    end
  end
end
