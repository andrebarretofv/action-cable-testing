# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "pry-byebug"

require "action_cable"
require "action-cable-testing"

require "active_support/testing/autorun"

# Require all the stubs and models
Dir[File.expand_path("stubs/*.rb", __dir__)].each { |file| require file }

# # Set test adapter and logger
ActionCable.server.config.cable = { "adapter" => "test" }
ActionCable.server.config.logger =
  ActiveSupport::TaggedLogging.new ActiveSupport::Logger.new(StringIO.new)

class ActionCable::TestCase < ActiveSupport::TestCase
  def wait_for_async
    wait_for_executor Concurrent.global_io_executor
  end

  def run_in_eventmachine
    yield
    wait_for_async
  end

  def wait_for_executor(executor)
    # do not wait forever, wait 2s
    timeout = 2
    until executor.completed_task_count == executor.scheduled_task_count
      sleep 0.1
      timeout -= 0.1
      raise "Executor could not complete all tasks in 2 seconds" unless timeout > 0
    end
  end
end
