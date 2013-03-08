# Rapidash

Rapidash is an opinionated core for you to build a client for your API on.  The goal is to define a standard way that developers can quickly write a client for the consumption of their RESTful API.

## Installation

Add this line to your application's Gemfile:

    gem 'rapidash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rapidash

## Usage

### Resources

Resources can be defined as follows:

    class Users < Rapidash::Base
    end

The URL of the resource will be inferred from the class name.  In this case Users.  If you want to override that, you can with the url method.

    class Users < Rapidash::Base
      url :members  # or url "members" is also supported
    end

### Client

The main thing a client must do is define a method, `oauth` and `http` are currently supported.  You can also define resources which links a resource as defined above to the client.

    class Client < Rapidash::Client
      method :oauth
      resource :users
    end

OAuth provides an initialize method which you can see in the Facebook client example.

Currently when using the HTTP method, you will need to define your own initialize method to set the site in use.

### Making calls

    client = Client.new
    client.site = "http://example.com/"
    client.users #Returns an instance of Users
    client.users! #Will make a call to "http://example.com/users
    client.users!(1) #Will make a call to http://example.com/users/1
    client.users!(params => {:page => 1}}) # Will make a call to http://example.com/users?page=1

## Example Clients

### Facebook

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

### Github

    require 'rapidash'

    class Users < Rapidash::Base
      def repos!
        self.url += "/repos"
        call!
      end
    end

    class Github < Rapidash::Client
      method :http
      resource :users

      def initialize
        @site = "https://api.github.com/"
      end
    end

    client = Github.new
    p client.users!("Gazler").name           #Gary Rennie
    p client.users("Gazler").repos![0].name  #Githug

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
