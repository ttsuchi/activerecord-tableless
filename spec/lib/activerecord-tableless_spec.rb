require 'active_record'
require 'activerecord-tableless'

describe "tabless defaults to raise" do
  class Chair < ActiveRecord::Base
    has_no_table
    column :id, :integer
    column :name, :string
  end

  subject { Chair.new }
  it ("should succeed"){ true == true}
end
