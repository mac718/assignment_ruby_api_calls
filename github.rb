require 'github_api'
require 'pp'
require 'pry'

class GithubAPIWrapper
  
  API_KEY = ENV['GITHUB_API_KEY']
  
  def initialize
    @github = Github.new(oauth_token: API_KEY)
  end

  def grab_repo_list
    @repos = @github.repos.list(user: 'mac718').body
  end

  def grab_commits(repo)
    @commits = @github.repos.commits.list('mac718', repo).body
  end

  def display_last_ten_repo_names
    last_ten_repos.each { |repo| puts repo['name'] }
  end

  def display_last_ten_commits_for_last_ten_repos
    commits = last_ten_commits_for_last_ten_repos
    commits.each do |repo_name, commit_messages|
      puts "#{repo_name}:"
      commit_messages.each { |message| puts message }
    end
  end

  def last_ten_repos
    @last_ten_repos = grab_repo_list.sort_by { |repo| repo['created_at'] }.reverse[0..9]
  end

  def last_ten_commits_for_last_ten_repos
    commit_list = Hash.new(0)
    last_ten_repos.each do |repo|
      commit_list["#{repo['name']}"] = []
      last_ten_commits = grab_commits(repo['name'])[0..9].map { |commit| commit['commit']['message'] }
      last_ten_commits.each do |commit|
        commit_list["#{repo['name']}"] << commit 
        binding.pry
      end
      sleep(1)
    end
    commit_list
  end

  def save_repos(response)
    File.open('git_repos.rb',"w") do |f|
      f.write(response)
    end
  end

  def save_commits(response)
    File.open('git_commits.rb',"w") do |f|
      f.write(response)
    end
  end
end

pp GithubAPIWrapper.new.last_ten_commits_for_last_ten_repos

#repos = g.grab_repo_list
#g.save_repos(repos)


