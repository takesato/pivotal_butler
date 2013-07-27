# -*- coding: utf-8 -*-
require 'cinch'
require 'pivotal-tracker'
require 'yaml'

config = YAML.load(File.read('config.yml'))
irc_setting = config['irc']
pivotal_setting = config['pivotal_tracker']

PivotalTracker::Client.token = pivotal_setting['api_token']
PivotalTracker::Client.use_ssl = true
PROJECT_ID = pivotal_setting['project_id']

bot = Cinch::Bot.new do
  configure do |c|
    c.nick     = irc_setting['nick']
    c.realname = irc_setting['realname']

    c.server   = irc_setting['server']
    c.channels = irc_setting['channels']
    c.password = irc_setting['password']
    c.port     = irc_setting['port']
    c.ssl.use  = irc_setting['use_ssl']
    c.encoding = irc_setting['encoding']
  end

  on :channel do |m|
    messages(*parse_message(m.params[1])).each { |message| m.reply message }
  end

  helpers do
    def parse_message(message)
      match = message.match(/#{self.bot.nick}: (.*) (.*)/)
      if match
        [get_type(match[1]), match[2]]
      else
        [nil, nil]
      end
    end

    def get_type(type)
      case type.upcase
      when "FEATURE", "TODO", "TASK", "MEMO", "メモ", "タスク" then "feature"
      when "CHORE" then "chore"
      when "BUG" then "bug"
      end
    end

    def messages(type, action)
      case action.downcase
      when 'started', 'unscheduled', 'finished', 'deliverd', 'rejected', 'accepted'
        get_stories(type, action)
      else
        add_story(type, action)
      end
    end

    def add_story(type, name)
      [] unless name
      project = PivotalTracker::Project.find(PROJECT_ID)
      project.stories.create(name: name, story_type: type)
      ["「#{name}」を #{type} として登録しました"]
    end

    def get_stories(type, state)
      project = PivotalTracker::Project.find(PROJECT_ID)
      stories = project.stories.all(current_state: state.downcase, story_type: [type]).map do |story|
        "#{story.id} #{story.name}"
      end
      stories = ["#{type} の #{state} は見付かりませんでした"] if stories == []
      stories
    end
  end
end

bot.start
