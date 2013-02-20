require 'sqlite3'
require 'active_record'
require 'activerecord-tableless'
require 'logger'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::Severity::UNKNOWN

class ChairFailure < ActiveRecord::Base
  has_no_table
  column :id, :integer
  column :name, :string
end

class ChairPretend < ActiveRecord::Base
  has_no_table :database => :pretend_success
  column :id, :integer
  column :name, :string
end

FileUtils.mkdir_p "tmp"
ActiveRecord::Base.establish_connection(:adapter  => 'sqlite3', :database => 'tmp/test.db')
ActiveRecord::Base.connection.execute("drop table if exists chairs")
ActiveRecord::Base.connection.execute("create table chairs (id INTEGER PRIMARY KEY, name TEXT )")

class Chair < ActiveRecord::Base
end

describe "tableless attributes" do

  subject { ChairFailure.new }
  it { should respond_to :id }
  it { should respond_to :id= }
  it { should respond_to :name }
  it { should respond_to :name= }

end

describe "tableless with fail_fast" do
  let!(:klass) { ChairFailure }
  subject { ChairFailure.new }

  describe "class" do
    if ActiveRecord::VERSION::STRING < "3.0"
      describe "#find" do
        it "raises ActiveRecord::Tableless::NoDatabase" do
          expect { klass.find(1) }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
        end
      end
      describe "#find(:all)" do
        it "raises ActiveRecord::Tableless::NoDatabase" do
          expect { klass.find(:all) }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
        end
      end
    else ## ActiveRecord::VERSION::STRING >= "3.0"
      describe "#all" do
        it "raises ActiveRecord::Tableless::NoDatabase" do
          expect { klass.all }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
        end
      end
    end
    describe "#create" do
      it "raises ActiveRecord::Tableless::NoDatabase" do
        expect { klass.create(:name => 'Jarl') }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
      end
    end
    describe "#destroy" do
      it "raises ActiveRecord::Tableless::NoDatabase" do
        expect { klass.destroy(1) }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
      end
    end
    describe "#destroy_all" do
      it "raises ActiveRecord::Tableless::NoDatabase" do
        expect { klass.destroy_all }.to raise_exception(ActiveRecord::Tableless::NoDatabase)
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

shared_examples_for "a succeeding database" do

  describe "class" do
    if ActiveRecord::VERSION::STRING < "3.0"
      describe "#find" do
        it "raises ActiveRecord::RecordNotFound" do
          expect { klass.find(314) }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
      describe "#find(:all)" do
        specify { klass.find(:all) == []}
      end
    else ## ActiveRecord::VERSION::STRING >= "3.0"
      describe "#all" do
        specify { klass.all == []}
      end
    end
    describe "#create" do
      specify { klass.create(:name => 'Jarl') == true }
    end
    describe "#destroy" do
      specify { klass.destroy(1) == true }
    end
    describe "#destroy_all" do
      specify { klass.destroy_all == true }
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

describe "tableless with real database" do
  ##This is only here to ensure that the shared examples are actually behaving like a real database.
  let!(:klass) { Chair }
  subject { Chair.new(:name => 'Jarl') }
  it_behaves_like "a succeeding database"
end

describe "tableless with succeeding database" do
  let!(:klass) { ChairPretend }
  subject { ChairPretend.new(:name => 'Jarl') }
  it_behaves_like "a succeeding database"
end
