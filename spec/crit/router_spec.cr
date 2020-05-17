require "../spec_helper"
require "../../src/crit/router"

describe Crit::Router do
  it "supports 'init'" do
    router = Crit::Router.new(["init"])
    router.supported?.should eq(true)
  end

  describe "dispatch!" do
    context "for unsupported intents" do
      it "rejects it" do
        router = Crit::Router.new ["unsupported_command"]

        expect_raises(Crit::UnknownCommand) do
          router.dispatch!
        end
      end

      it "complains with a helpful message" do
        router = Crit::Router.new ["unsupported_command"]

        expect_raises(Crit::UnknownCommand, "Unsupported command: 'unsupported_command'") do
          router.dispatch!
        end
      end
    end

    context "for supported intents" do
      # After some 15 minutes of thought on this, I settled for doing this the
      # wrong way so as not to be stuck on analysis paralysis, trying to get
      # this right the first time.
      #
      # My original thought was to use reflection and delegate the command
      # intellectually from the supported commands. So "crit init" would
      # delegate to the Crit::InitCommand. In Ruby, `constantize` would come in
      # handy to help me do this. Crystal has macros... but I have not been able
      # to wrap my head around this in 15 minutes.
      #
      # Another way I thought to tackle this was to use the factory pattern, but
      # then i got stuck on how to test it also.
      #
      # All these considered, I thought to go for the if-else branch method, and
      # test each branch in its own test case. It's not the optimal
      # implementation, but it's definitely the fastest.
      #
      # I apologize to my future self, or anyone who chooses to extend this.
    end
  end

  describe "route" do
    it "routes 'init' to the InitCommand" do
      router = Crit::Router.new ["init"]

      command = router.route

      command.is_a?(Crit::InitCommand).should eq(true)
    end
  end
end
