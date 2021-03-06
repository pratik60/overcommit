module Overcommit::HookContext
  # Contains helpers related to the context with which a hook is being run.
  #
  # It acts as an adapter to the arguments passed to the hook, as well as
  # context-specific information such as staged files, providing a single source
  # of truth for this context.
  #
  # This is also important to house in a separate object so that any
  # calculations can be memoized across all hooks in a single object, which
  # helps with performance.
  #
  # @abstract
  class Base
    # Creates a hook context from the given configuration and input options.
    #
    # @param config [Overcommit::Configuration]
    # @param args [Array<String>]
    # @param input [IO] standard input stream
    def initialize(config, args, input)
      @config = config
      @args = args
      @input = input
    end

    # Returns the camel-cased type of this hook (e.g. PreCommit)
    #
    # @return [String]
    def hook_class_name
      self.class.name.split('::').last
    end

    # Returns the snake-cased type of this hook (e.g. pre_commit)
    #
    # @return [String]
    def hook_type_name
      Overcommit::Utils.snake_case(hook_class_name)
    end

    # Returns the actual name of the hook script being run (e.g. pre-commit).
    #
    # @return [String]
    def hook_script_name
      hook_type_name.gsub('_', '-')
    end

    # Initializes anything related to the environment.
    #
    # This is called before the hooks are run by the [HookRunner]. Different
    # hook types can perform different setup.
    def setup_environment
      # Implemented by subclass, if applicable
    end

    # Resets the environment to an appropriate state.
    #
    # This is called after the hooks have been run by the [HookRunner].
    # Different hook types can perform different cleanup operations, which are
    # intended to "undo" the results of the call to {#setup_environment}.
    def cleanup_environment
      # Implemented by subclass, if applicable
    end

    # Returns a list of files that have been modified.
    #
    # By default, this returns an empty list. Subclasses should implement if
    # there is a concept of files changing for the type of hook being run.
    #
    # @return [Array<String>]
    def modified_files
      []
    end

    # Returns an array of lines passed to the hook via the standard input
    # stream.
    #
    # @return [Array<String>]
    def input_lines
      @input_lines ||= @input.read.split("\n")
    end
  end
end
