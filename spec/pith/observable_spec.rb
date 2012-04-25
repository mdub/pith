require 'spec_helper'
require "pith/observable"

class SimpleObservable

  include Pith::Observable

end

class SimpleObserver

  def initialize(output, id)
    @output = output
    @id = id
  end

  def notified
    @output << @id
  end

end

describe Pith::Observable do

  let(:observable) { SimpleObservable.new }
  let(:observer_output) { [] }

  def make_observer(id)
    SimpleObserver.new(observer_output, id)
  end

  before do
    @observer1 = make_observer(1)
    @observer2 = make_observer(2)
    observable.add_observer(@observer1, :notified)
    observable.add_observer(@observer2, :notified)
  end

  describe "#notify_observers" do

    before do
      observable.notify_observers
    end

    it "invokes the notification methods on the observers" do
      observer_output.sort.should == [1, 2]
    end

  end

  context "when the observers are garbage-collected" do

    before do
      @observer1 = nil
      ObjectSpace.garbage_collect
    end

    describe "#notify_observers" do

      before do
        observable.notify_observers
      end

      it "does not notify them" do
        observer_output.sort.should == [2]
      end

    end

  end

end
