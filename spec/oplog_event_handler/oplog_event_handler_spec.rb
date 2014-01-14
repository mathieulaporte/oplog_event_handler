require 'spec_helper'

describe "OplogEventHandler" do

  before do
    @log1 = { "ts"  => 354235435435435, "h"  => -1856809684451276882, "op"  => "u", "ns"  => "az_app_2_test.subjects", "o2"  => { "_id"  => BSON::ObjectId("50c21295caa8618d99001e56") }, "o"  => { "$addToSet"  => { "conversation_ids"  => BSON::ObjectId("50c21296caa8618d99001e6c") } } }
  end

  subject { class Test; include OplogEventHandler; end.new }

  describe "#extract_db_name(doc)" do

    context "whith a valid doc" do
      it { subject.send(:extract_db_name, @log1).should == 'az_app_2_test' }
    end

  end

  describe "#extract_collection_name(doc)" do

    context "with a valid doc" do
      it { subject.send(:extract_collection_name, @log1).should == 'subjects' }
    end

  end

  describe "#extract_operation(doc)" do

    context "for insert" do
      it { subject.send(:extract_operation, @log1.merge({'op' => 'i'})).should == :insert }
    end

    context "for update" do
      it { subject.send(:extract_operation, @log1.merge({'op' => 'u'})).should == :update }
    end

    context "for delete" do
      it { subject.send(:extract_operation, @log1.merge({'op' => 'd'})).should == :delete }
    end

    context "for command" do
      it { subject.send(:extract_operation, @log1.merge({'op' => 'c'})).should == :dbcmd }
    end

    context "for noop" do
      it { subject.send(:extract_operation, @log1.merge({'op' => 'n'})).should == :noop }
    end

  end


  context "when i instantiate 2 events handlers" do

    before do
      class A
        include OplogEventHandler
        connect_to host: '192.168.0.10', port: 1234
        for_db :test1 do
          on_insert :in => :users, :call => :test_user
        end
      end
      class B
        include OplogEventHandler
        connect_to host: '127.0.0.1', port: 1234
        for_db :test do
          on_insert :in => :subjects, :call => :test_user2
        end
      end
    end


    it { A.mapping.should_not == B.mapping}

    it { A.host.should_not == B.host}

  end


end
