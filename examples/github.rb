require 'rapidash'

class Repo < Rapidash::Base
  def repo!(owner, repo)
    self.url += "/#{owner}/#{repo}"
    call!
  end
end

class User < Rapidash::Base
  resource :repos
end

class Emoji < Rapidash::Base
end

class Event < Rapidash::Base
end

class Gist < Rapidash::Base

  def public!
    self.url += "/public"
    call!
  end

end

class Organisation < Rapidash::Base
  url "orgs"
end

class Limit < Rapidash::Base
  url "rate_limit"
end


class Client < Rapidash::Client
  method :http
  site "https://api.github.com/"
  resource :users, :repos, :emojis, :events, :gists, :organisations, :limit
end

client = Client.new

p client.limit!.rate.remaining

p client.gists.public!

client.users("Gazler").repos!.each do |repo|
  p repo.name
end

client.emojis!.each do |emoji|
  p emoji
end

client.events!.each do |event|
  p event
end

p client.organisations!("powershift")

p client.repos.repo!("Gazler", "rapidash")
