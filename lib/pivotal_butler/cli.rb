# -*- coding: utf-8 -*-
module PivotalButler
  class Cli
    def self.start
      self.new.start
    end

    def start
      PivotalTracker::Client.token = PivotalButler::Setting.pivotal_tracker.api_token
      PivotalTracker::Client.use_ssl = true

      bot = Cinch::Bot.new do
        configure do |c|
          c.nick     = PivotalButler::Setting.irc.nick
          c.realname = PivotalButler::Setting.irc.realname

          c.server   = PivotalButler::Setting.irc.server
          c.channels = PivotalButler::Setting.irc.channels
          c.password = PivotalButler::Setting.irc.password
          c.port     = PivotalButler::Setting.irc.port
          c.ssl.use  = PivotalButler::Setting.irc.use_ssl
          c.encoding = PivotalButler::Setting.irc.encoding
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
            project = PivotalTracker::Project.find(PivotalButler::Setting.pivotal_tracker.project_id)
            project.stories.create(name: name, story_type: type)
            ["「#{name}」を #{type} として登録しました"]
          end

          def get_stories(type, state)
            project = PivotalTracker::Project.find(PivotalButler::Setting.pivotal_tracker.project_id)
            stories = project.stories.all(current_state: state.downcase, story_type: [type]).take(10).map do |story|
              humanize story
            end
            stories = ["#{type} の #{state} は見付かりませんでした"] if stories == []
            stories
          end

          def humanize(story)
            message = PivotalButler::Setting.pivotal_tracker.format
            %w(nick id type state story url).each do |convert_str|
              message = message.gsub(convert_str, PivotalButler::Story.send(convert_str, story))
            end
            message
          end
        end
      end

      bot.start
    end
  end
end
