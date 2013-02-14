require 'spec_helper'

describe "OplogEventHandler" do

  before do
    @log1 = { "ts"  => 354235435435435, "h"  => -1856809684451276882, "op"  => "u", "ns"  => "az_app_2_test.subjects", "o2"  => { "_id"  => BSON::ObjectId("50c21295caa8618d99001e56") }, "o"  => { "$addToSet"  => { "conversation_ids"  => BSON::ObjectId("50c21296caa8618d99001e6c") } } }
  end

  subject { OplogEventHandler.new }

  describe "#extract_db_name(doc)" do

    context "whith a valid doc" do
      it { subject.send(:extract_db_name, @log1).should == 'az_app_2_test' }
    end

  end

  describe "#extract_collection_name(doc)" do

    context "with a valid doc" do
      it { OplogEventHandler.new.send(:extract_collection_name, @log1).should == 'subjects' }
    end

  end

  describe "#extract_operation(doc)" do

    context "for insert" do
      it { OplogEventHandler.new.send(:extract_operation, @log1.merge({'op' => 'i'})).should == :insert }
    end

    context "for update" do
      it { OplogEventHandler.new.send(:extract_operation, @log1.merge({'op' => 'u'})).should == :update }
    end

    context "for delete" do
      it { OplogEventHandler.new.send(:extract_operation, @log1.merge({'op' => 'd'})).should == :delete }
    end

    context "for command" do
      it { OplogEventHandler.new.send(:extract_operation, @log1.merge({'op' => 'c'})).should == :dbcmd }
    end

    context "for noop" do
      it { OplogEventHandler.new.send(:extract_operation, @log1.merge({'op' => 'n'})).should == :noop }
    end

  end


end