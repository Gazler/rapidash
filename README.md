# Rapidash [![Build Status](https://travis-ci.org/Gazler/rapidash.png?branch=master)](https://travis-ci.org/Gazler/rapidash)

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

### Resources

Resources can be defined as follows:

```ruby
class Users < Rapidash::Base
end
```

The URL of the resource will be inferred from the class name.  In this case Users.  If you want to override that, you can with the url method.

```ruby
class Users < Rapidash::Base
  url :members  # or url "members" is also supported
end
```

Resources can exist inside other resources.  For example, on Github, a user has repositories.  The following could be how you build the resources:

```ruby
class Repos < Rapidash::Base
end

class Users < Rapidash::Base
  resource :repos
end
```

#### Root elements

A root element can be set for create and post actions

```ruby
class Posts < Rapidash::Base
end

client.posts.create!({:post => {:name => "a post"}})
```

With a root element, the code would look like this:

```ruby
class Posts < Rapidash::Base
  root :post
end

client.posts.create!(:name => "a post")
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

class Repos < Rapidash::Base

class Users < Rapidash::Base
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thanks to [@Sid3show](https://github.com/Sid3show) for the sweet logo!
