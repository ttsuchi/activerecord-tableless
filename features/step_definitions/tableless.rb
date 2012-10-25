Given /^I delete all migrations$/ do
  steps %{
    When I successfully run `bash -c 'rm db/migrate/*.rb'`
  }
end

Given /^I update my new user model to be tableless$/ do
  in_current_dir do
    file_name = 'app/models/user.rb'
    content = File.read(file_name)
    content.gsub!(/^(class .* < ActiveRecord::Base)$/, "\\1\n" + <<-TABLELESS)
  has_no_table
  column :id, :integer
  column :name, :string

TABLELESS
    File.open(file_name, 'w') { |f| f << content }
  end
end

Given /^I update my users controller to render instead of redirect$/ do
  in_current_dir do
    file_name = 'app/controllers/users_controller.rb'
    content = File.read(file_name)
    content.gsub!("@user = User.new(params[:user])",
                  "@user = User.new(params[:user]); @user.id = 1")

    content.gsub!("if @user.save",
                  "if @user.valid?")

    content.gsub!(/format.html \{ redirect_to[\( ]@user, .*? \}/,
                  "format.html { render :action => 'show' }")
    File.open(file_name, 'w') { |f| f << content }
  end
end
