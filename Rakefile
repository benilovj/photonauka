require 'rubygems'
require 'hotcocoa/rake_tasks'

require 'rspec/core/rake_task'

require 'date'

desc "Run specs"
RSpec::Core::RakeTask.new

def path_to_source_dmg
  @path_to_source_dmg ||= FileList['*.dmg'].first
end

def target_dmg_name
  path_to_source_dmg.pathmap("%n") + "-" + AppVersion.new.build_version + '.dmg'
end

def dropbox_public_path
  ENV['DEBUG'] ? ENV['TMPDIR'] : File.join(ENV["HOME"], "Dropbox", "Public")
end

module Github
  class Client
    def initialize
      require 'rest-client'
      require 'json'
    end

    def get(url, options = {})
      JSON.parse(RestClient.get(basepath + url, :params => options))
    end

    def post(url, options = {})
      JSON.parse(RestClient.post(basepath + url, options.to_json))
    end

    def patch(url, options = {})
      JSON.parse(RestClient.patch(basepath + url, options.to_json))
    end

    protected
    def basepath
      "https://#{credentials}@api.github.com/repos/benilovj/photonauka"
    end

    def credentials
      @credentials ||= File.read(File.join(ENV['HOME'], ".github")).strip
    end
  end

  class Milestone
    def initialize(number)
      @number = number
    end

    def assign_all(issues)
      issues.each do |issue|
        Client.new.patch("/issues/#{issue.number}", :milestone => @number)
      end
    end

    def issues
      response = Client.new.get('/issues', :milestone => @number, :state => "closed")
      response.map {|issue_json| Issue.new(issue_json["number"], issue_json["html_url"], issue_json["title"])}
    end

    def self.create_for_today
      response = Client.new.post('/milestones', :title => Date.today.strftime("%Y-%m-%d"), :due_on => Date.today.iso8601)
      new(response["number"])
    end
    
    def self.todays_milestone
      response = Client.new.get('/milestones', :state => "closed")
      milestone_number = response.detect {|milestone_json| milestone_json["title"] == Date.today.strftime("%Y-%m-%d") }["number"]
      new(milestone_number)
    end
  end

  class Issue < Struct.new(:number, :url, :title)
    def self.find_closed_without_milestone
      response = Client.new.get('/issues', :milestone => "none", :state => "closed")
      response.map {|issue_json| Issue.new(issue_json["number"], issue_json["html_url"], issue_json["title"]) }
    end
  end

  class ReleaseNotes
    def initialize(issues)
      @issues = issues
    end

    def to_s
      require 'haml'
      template = File.read('sparkle_feed/release_notes.haml')
      Haml::Engine.new(template).render(Object.new, :issues => @issues)
    end
  end
end

class AppVersion
  def build_version
    appspec.version
  end

  def marketing_version
    appspec.short_version
  end

  protected
  def appspec
    appspec_files = FileList["#{Rake.application.original_dir}/*.appspec"]
    Application::Specification.load appspec_files.first
  end
end

desc "Get signature for app"
task :sign do
  @signature = `sparkle_feed/sign_update.rb #{path_to_source_dmg} sparkle_feed/dsa_priv.pem`
  puts "DSA signature for #{path_to_source_dmg}: #{@signature}"
end

task :create_release_milestone do
  milestone = Github::Milestone.create_for_today
  issues = Github::Issue.find_closed_without_milestone
  milestone.assign_all(issues)
end

task :release_notes do
  issues = Github::Milestone.todays_milestone.issues
  @release_notes = Github::ReleaseNotes.new(issues).to_s
  puts "Release notes: \n" + @release_notes
end

task :upload_dmg => :dmg do
  cp path_to_source_dmg, File.join(dropbox_public_path, target_dmg_name)
end

task :generate_sparkle_feed => [:sign, :release_notes] do
  require 'haml'
  
  template = File.read('sparkle_feed/feed.haml')
  
  File.open(File.join(dropbox_public_path, "feed.xml"), "w") do |f|
    f << Haml::Engine.new(template).render(Object.new,
      :release_notes     => @release_notes,
      :release_dmg       => target_dmg_name,
      :dmg_signature     => @signature,
      :build_version     => AppVersion.new.build_version,
      :marketing_version => AppVersion.new.marketing_version,
      :release_name      => Date.today.strftime("%Y-%m-%d")
    )
  end
end

desc "Push a release of the app"
task :release => [:create_release_milestone, :dmg, :upload_dmg, :generate_sparkle_feed]

task :dmg => :spec

task :default => :run
