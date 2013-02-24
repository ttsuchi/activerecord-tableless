require 'sqlite3'
require 'active_record'
require 'activerecord-tableless'
require 'logger'

def make_tableless_model(database = nil, nested = nil)
  eval <<EOCLASS
  class Chair < ActiveRecord::Base
    #{database ? "has_no_table :database => :#{database}" : 'has_no_table'}
    column :id, :integer
    column :name, :string
    #{if nested 
      '
      has_many :arm_rests
      accepts_nested_attributes_for :arm_rests 
      '
      end}
  end
EOCLASS
  if nested
  eval <<EOCLASS
    class ArmRest < ActiveRecord::Base
      #{database ? "has_no_table :database => :#{database}" : 'has_no_table'}
      belongs_to :chair
      column :id, :integer
      column :chair_id, :integer
      column :name, :string
    end
EOCLASS
  end
end

def remove_models
  Object.send(:remove_const, :Chair) rescue nil
  Object.send(:remove_const, :ArmRest) rescue nil
end

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::Severity::UNKNOWN

shared_examples_for "an active record" do
  it { should respond_to :id }
  it { should respond_to :id= }
  it { should respond_to :name }
  it { should respond_to :name= }
  it { should respond_to :update_attributes }
end

shared_examples_for "a nested active record" do
  if ActiveRecord::VERSION::STRING < "3.2"
    describe "conllection#build" do
      specify do
        subject.arm_rests.build({:name => 'nice arm_rest'}).should be_an_instance_of(ArmRest)
      end
    end
  end
  describe "conllection#<<" do
    specify do
      (subject.arm_rests << ArmRest.new({:name => 'nice arm_rest'})).should have(1).items
    end
    describe "result" do
      before(:each) do
        subject.arm_rests << [ArmRest.new({:name => 'left'}),
                              ArmRest.new({:name => 'right'})]
      end
      specify do
        subject.arm_rests[0].name.should == 'left'
      end
      specify do
        subject.arm_rests[1].name.should == 'right'
      end
    end
  end
end

shared_examples_for "a tableless model with fail_fast" do
  it_behaves_like "an active record"
  describe "class" do
    if ActiveRecord::VERSION::STRING < "3.0"
      describe "#find" do
        it "raises ActiveRecord::Tableless::NoDatabase" do
          expect { Chair.find(1) }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
        end
      end
      describe "#find(:all)" do
        it "raises ActiveRecord::Tableless::NoDatabase" do
          expect { Chair.find(:all) }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
        end
      end
    else ## ActiveRecord::VERSION::STRING >= "3.0"
      describe "#all" do
        it "raises ActiveRecord::Tableless::NoDatabase" do
          expect { Chair.all }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
        end
      end
    end
    describe "#create" do
      it "raises ActiveRecord::Tableless::NoDatabase" do
        expect { Chair.create(:name => 'Jarl') }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
      end
    end
    describe "#destroy" do
      it "raises ActiveRecord::Tableless::NoDatabase" do
        expect { Chair.destroy(1) }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
      end
    end
    describe "#destroy_all" do
      it "raises ActiveRecord::Tableless::NoDatabase" do
        expect { Chair.destroy_all }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
      end
    end
  end

  describe "#save" do
    it "raises ActiveRecord::Tableless::NoDatabase" do
      expect { subject.save }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
    end
  end
  describe "#save!" do
    it "raises ActiveRecord::Tableless::NoDatabase" do
      expect { subject.save! }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
    end
  end
  describe "#reload" do
    it "raises ActiveRecord::Tableless::NoDatabase" do
      expect { subject.reload }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
    end
  end
  describe "#update_attributes" do
    it "raises ActiveRecord::Tableless::NoDatabase" do
      expect { subject.update_attributes(:name => 'Jarl') }.to raise_exception(StandardError)
    end
  end
end

describe "Tableless with fail_fast" do
  before(:all) {make_tableless_model(nil, nil)}
  after(:all){ remove_models }
  subject { Chair.new }
  it_behaves_like "a tableless model with fail_fast"
end

describe "Tableless nested with fail_fast" do
  before(:all) {make_tableless_model(nil, true)}
  after(:all){ remove_models }
  describe "#new" do
    it "accepts attributes" do
      Chair.new(:name => "Jarl").should be_an_instance_of(Chair)
    end
    it "assign attributes" do
      Chair.new(:name => "Jarl").name.should == "Jarl"
    end
    it "accepts nested attributes" do
      Chair.new(:name => "Jarl", :arm_rests => [
                                                ArmRest.new(:name => 'left'),
                                                ArmRest.new(:name => 'right'),
                                               ]).
        should be_an_instance_of(Chair)
    end
    it "assign nested attributes" do
      Chair.new(:name => "Jarl", :arm_rests => [
                                                ArmRest.new(:name => 'left'),
                                                ArmRest.new(:name => 'right'),
                                               ]).
        should have(2).arm_rests
    end
  end
  subject { Chair.new }
  it_behaves_like "a tableless model with fail_fast"
  it_behaves_like "a nested active record"
  describe "#update_attributes" do
    it "raises ActiveRecord::Tableless::NoDatabase" do
      expect do
        subject.update_attributes(:arm_chair => {:name => 'nice arm_rest'})
      end.to raise_exception(StandardError)
    end
  end
end

shared_examples_for "a succeeding database" do
  it_behaves_like "an active record"
  describe "class" do
    if ActiveRecord::VERSION::STRING < "3.0"
      describe "#find" do
        it "raises ActiveRecord::RecordNotFound" do
          expect { Chair.find(314) }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
      describe "#find(:all)" do
        specify { Chair.find(:all).should == []}
      end
    else ## ActiveRecord::VERSION::STRING >= "3.0"
      describe "#all" do
        specify { Chair.all.should == []}
      end
    end
    describe "#create" do
      specify { Chair.create(:name => 'Jarl').should be_an_instance_of(Chair) }
    end
    describe "#destroy" do
      specify { Chair.destroy(1).should be_an_instance_of(Chair) }
    end
    describe "#destroy_all" do
      specify { Chair.destroy_all.should == [] }
    end
  end

  describe "#save" do
    specify { subject.save.should == true }
  end
  describe "#save!" do
    specify { subject.save!.should == true }
  end
  describe "#reload" do
    before { subject.save! }
    specify { subject.reload.should == subject }
  end
  describe "#update_attributes" do
    specify { subject.update_attributes(:name => 'Jarl Friis').should == true }
  end
end

describe "Active record with real database" do
  ##This is only here to ensure that the shared examples are actually behaving like a real database.
  before(:all) do
    FileUtils.mkdir_p "tmp"
    ActiveRecord::Base.establish_connection(:adapter  => 'sqlite3', :database => 'tmp/test.db')
    ActiveRecord::Base.connection.execute("drop table if exists chairs")
    ActiveRecord::Base.connection.execute("create table chairs (id INTEGER PRIMARY KEY, name TEXT )")
    
    class Chair < ActiveRecord::Base
    end
  end
  after(:all) do
    remove_models
    ActiveRecord::Base.clear_all_connections!
  end

  subject { Chair.new(:name => 'Jarl') }
  it_behaves_like "a succeeding database"
end

describe "Tableless with succeeding database" do
  before(:all) { make_tableless_model(:pretend_success, nil) }
  after(:all){ remove_models }
  subject { Chair.new(:name => 'Jarl') }
  it_behaves_like "a succeeding database"
end
