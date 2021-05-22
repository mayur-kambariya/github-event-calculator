## Install gem install httparty if httparty not working
require 'httparty'

class GithubEvent
  ## Github events list
  GITHUB_EVENT = {
    IssuesEvent: 7,
    IssueCommentEvent: 6,
    PushEvent: 5,
    PullRequestReviewCommentEvent: 4,
    WatchEvent: 3,
    CreateEvent: 2,
    PullRequestEvent: 2,
    DeleteEvent: -1
  }

  attr_accessor :user, :events, :score
  
  def initialize user
    @user = user
    @score = 0
  end
  
  ## Fetch events from  github using httparty
  def fetch_events
    response = HTTParty.get("https://api.github.com/users/#{user}/events")
    if response.code == 200
      @events = JSON.parse(response.body)
    else
      @events = []
      raise NoRecordFound      
    end
  end

  ## Calculate score base on events list
  def calculate_score
    if events.size > 0
      events.map{|a| a['type']}.compact.group_by(&:to_s).map do |key, value| 
        event_score = GITHUB_EVENT[key.to_sym] || 0
        @score += event_score * value.count
      end
    else
      @score = 0
    end
  end

  ## Score
  def get_score
    puts "Github user #{user} score is: #{score}"
  end
end

puts "Please enter github user name:"
github_user = gets.chomp
github = GithubEvent.new github_user
begin
  github.fetch_events
rescue => NoRecordFound
  puts "No user found with #{github_user} name"
end
github.calculate_score
github.get_score