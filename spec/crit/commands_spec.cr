require "../spec_helper"
require "../../src/crit/commands"

describe Crit::InitCommand do
end

describe Crit::AddCommand do
  describe "initialize" do
    context "without paths" do
      it "is an illegal command" do
        expect_raises(Crit::IllegalCommand) do
          Crit::AddCommand.new [] of String
        end
      end
    end
  end
end
