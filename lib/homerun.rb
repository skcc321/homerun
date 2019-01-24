require "homerun/version"
require 'singleton'

module Homerun
  class Error < StandardError; end

  class Instruction
    include Singleton

    attr_reader :steps, :context

    def initialize
      super

      @steps = []
      @context = {}
    end

    def add_step(step)
      @steps << step
    end

    def self.step(item, failure: nil, success: nil, name: nil)
      instance.add_step({ item: item, failure: failure, success: success, name: name })
    end

    def self.call(ctx)
      @context = ctx.dup

      cur = 0

      while cur < instance.steps.count do
        step = instance.steps[cur]

        pos = ->(_name) {
          instance.steps.index(instance.steps.find { |x| x[:name] == _name })
        }

        if step[:item].call(instance.context)
          if step[:success]
            cur = pos.call(step[:success])
            next
          else
            cur += 1
          end
        else
          if step[:failure]
            cur = pos.call(step[:failure])
            next
          else
            cur = instance.steps.count
          end
        end
      end
    end
  end
end
