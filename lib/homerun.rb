require "homerun/version"
require 'singleton'
require 'pry'

module Homerun
  class Error < StandardError; end

  class Instruction
    include Singleton

    attr_reader :steps, :ctx

    def initialize
      super

      @steps = []
      @ctx = { _pass: true }
    end

    def add_step(step)
      @steps << step
    end

    def set_ctx(_ctx)
      @ctx = { **ctx, **_ctx }
    end

    def set_pass(val)
      @ctx[:_pass] = val
    end

    def self.step(item, failure: nil, success: nil, name: nil)
      instance.add_step({ item: item, failure: failure, success: success, name: name })
    end

    def self.call(_ctx)
      instance.set_ctx(_ctx)

      cur = 0

      while cur < instance.steps.count do
        step = instance.steps[cur]

        pos = ->(_name) {
          instance.steps.index(instance.steps.find { |x| x[:name] == _name })
        }

        if step[:item].call(instance.ctx)
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
            instance.set_pass(false)
            cur = instance.steps.count
          end
        end
      end

      if block_given?
        yield(instance.ctx) if instance.ctx[:_pass]
      end

      instance.ctx
    end
  end
end
