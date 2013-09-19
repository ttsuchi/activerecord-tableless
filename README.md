ActiveRecord Tableless
======================

[![Build Status](https://secure.travis-ci.org/softace/activerecord-tableless.png)](http://travis-ci.org/softace/activerecord-tableless)
[![Dependency Status](https://gemnasium.com/softace/activerecord-tableless.png)](https://gemnasium.com/softace/activerecord-tableless)
[![Code Climate](https://codeclimate.com/github/softace/activerecord-tableless.png)](https://codeclimate.com/github/softace/activerecord-tableless)

A single implementation of the ActiveRecord Tableless pattern for any
Rails project or other Ruby project that uses ActiveRecord.

Why, why, why
-------------

Why would you ever consider this gem as opposed to ActiveModel.

In Rails 2 ActiveModel does not exists (this is when it all started; see Hitosry section)

In Rails 3 there is an Active Model API, where you can use some
features of Active Record in other classes. Yehuda Katz has written
[a nice introduction about this](http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/).

In Rails 4 basic features of the Active Model API can be activated
by including
[ActiveModel:Model](http://api.rubyonrails.org/classes/ActiveModel/Model.html)
in the model. Carlos Antônio has written
[a nice tutorial about this](http://blog.plataformatec.com.br/2012/03/barebone-models-to-use-with-actionpack-in-rails-4-0/).

However neither the Active Model API (Rails 3) nor the
ActiveModel::Model (Rails 4) supports relations and nested attributes.


Installation
------------

ActiveRecord Tableless is distributed as a gem, which is how it should
be used in your app.

Include the gem in your Gemfile:

    gem "activerecord-tableless", "~> 1.0"


Supported Versions
------------------

Supported version are ActiveRecord version **2.3.x**, **3.0.x**
series, **3.2.x** series and **4.x** series

You may be able to make it work with 3.1.X, but you should expect to
put some time in it.

Usage
-----

Define a model like this:

    class ContactMessage < ActiveRecord::Base
      has_no_table
      column :name, :string
      column :email, :string
      validates_presence_of :name, :email
    end

You can now use the model in a view like this:

    <%= form_for :message, @message do |f| %>
      Your name: <%= f.text_field :name %>
      Your email: <%= f.text_field :email %>
    <% end %>

And in the controller:

    def message
      @message = ContactMessage.new
      if request.post?
        @message.attributes = params[:message]
        if @message.valid?
          # Process the message...
        end
      end
    end

For Rails 2.3.x series you need to add this line in the top of your model file.

    require 'activerecord-tableless'

If you wish (this is not recommended), you can pretend you have a succeeding database by using

    has_no_table :database => :pretend_success


Development
-----------

To start develop, please download the source code

    git clone git://github.com/softace/activerecord-tableless.git

When downloaded, you can start issuing the commands like

    bundle install
    bundle exec rake appraisal:gemfiles
    bundle exec rake appraisal:install
    bundle exec rake appraisal

Or you can see what other options are there:

    bundle exec rake -T


History
-------

Originally this code was implemented for Rails 2 by Kenneth
Kalmer. For Rails 3 the need for this functionality was reduced
dramatically due to the introduction of ActiveModel. But because the
ActiveModel does not support relations and nested attributes the
existence of this gem is still justified.

For a history of technical implementation details feel free to take a
look in the git log :-)


Copyright
---------

Copyright (c) Jarl Friis. See LICENSE.txt for
further details.

