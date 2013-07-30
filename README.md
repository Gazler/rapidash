# Rapidash [![Build Status](https://travis-ci.org/Gazler/rapidash.png?branch=master)](https://travis-ci.org/Gazler/rapidash) [![Coverage Status](https://coveralls.io/repos/Gazler/rapidash/badge.png?branch=master)](https://coveralls.io/r/Gazler/rapidash?branch=master)

![Rapidash](http://rapidashgem.com/images/rapidash.png)

Rapidash is a core for you to build a client for your API on.  The goal is to define a standard way that developers can quickly write a client for the consumption of their RESTful API.

## Installation

Add this line to your application's Gemfile:

    gem 'rapidash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rapidash

## Usage

A screencast on Rapidash is available to watch in mp4 and ogv formats.

 * [Rapidash Screencast mp4](http://screencasts.gazler.com/rapidash.mp4)
 * [Rapidash Screencast ogv](http://screencasts.gazler.com/rapidash.ogv)

### Sample Rails app

A sample rails app is available at [https://github.com/Gazler/rapidash-tester](https://github.com/Gazler/rapidash-tester) it provides a rails server and a Rapidash client.  Please note that the client is also used as a form of integration test for rapidash.

### Resources

Resources can be defined as follows:

```ruby
class Users < Rapidash::Base
end
```

The URL of the resource will be inferred from the class name.  In this case Users.  If you want to override that, you can with the url method.

```ruby
class User < Rapidash::Base
  url :members  # or url "members" is also supported
end
```

Resources can exist inside other resources.  For example, on Github, a user has repositories.  The following could be how you build the resources:

```ruby
class Repo < Rapidash::Base
end

class User < Rapidash::Base
  resource :repos
end
```

#### Root elements

A root element can be set for create and post actions

```ruby
class Post < Rapidash::Base
end

client.posts.create!({:post => {:name => "a post"}})
```

With a root element, the code would look like this:

```ruby
class Post < Rapidash::Base
  root :post
end

client.posts.create!(:name => "a post")
```

### Class Names and Classes In Different Modules

If you wish to use a class in a different module or a class with a different name as the class for your resource then you can use the `:class_name` option.

```ruby
module MyModule
  class MyResource < Rapidash::Base
  end
end

class AnotherResource < Rapidash::Base
  resource :my_cool_resource, :class_name => "MyModule::MyResource"
end
```


### Collections

The collection method allows you to add methods to a resource.

```ruby
class Project < Rapidash::Base
  collection :archived
end

# creates the method below which performs a
# GET /projects/archived
client.projects.archived!

class Project < Rapidash::Base
  collection :delete_all, path: 'destroy', method: :post
end

# creates the method below which performs a
# POST /projects/destroy
client.projects.delete_all!
```

### Client

The main thing a client must do is define a method, `oauth` and `http` are currently supported.  You can also define resources which links a resource as defined above to the client.

```ruby
class Client < Rapidash::Client
  method :oauth
  resource :users, :repos #An array can be passed through
  use_patch # This will use PATCH when updating instead of POST
  extension :json #Append the extension fo the urls
end
```



OAuth provides an initialize method which you can see in the Facebook client example.

Currently when using the HTTP method, you will need to define your own initialize method to set the site in use.

### Making calls

```ruby
client = Client.new
client.site = "http://example.com/"
client.users                                            #Returns an instance of Users
client.users!                                           #Will make a call to "http://example.com/users.json
client.users!(1)                                        #Will make a call to http://example.com/users/1.json
client.users!(params => {:page => 1}})                  #Will make a call to http://example.com/users.json?page=1
client.users.create!({:user => {:name => "Gazler"}})    #POST requst to /users.json
client.users(1).update!({:user => {:name => "Gazler"}}) #PUT or PATCH requst to /users.json
client.users(1).delete!                                 #DELETE requst to /users.json
```

## Example Clients

### Facebook

```ruby
require 'rapidash'

class Me < Rapidash::Base
  url "me"
end

class Facebook < Rapidash::Client
  method :oauth
  resource :me
end

client = Facebook.new({
  :site => "https://graph.facebook.com",
  :uid => "YOUR_ID",
  :secret => "YOUR_SECRET",
  :access_token => "YOUR_TOKEN"
})
p client.me!.first_name #Gary
```

### Github

```ruby
require 'rapidash'

class Repo < Rapidash::Base
end

class User < Rapidash::Base
  resource :repos
end

class Github < Rapidash::Client
  method :http
  resource :users
  site "https://api.github.com/"
end

client = Github.new
p client.users!("Gazler").name           #Gary Rennie
p client.users("Gazler").repos![0].name  #Githug
```

### HTTP Authentication

```ruby
require 'rapidash'

class Client < Rapidash::Client
  method :http
  site "your site"
end

client = Client.new({
  :login => "your login",
  :password => "your password",
})
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Write your tests, start and check coverage: open file coverage/index.html in your browser. Must be 100.0% covered
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request (into the development branch)

## Credits

Thanks to [@Sid3show](https://github.com/Sid3show) for the sweet logo!
