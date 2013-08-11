# -*- coding: utf-8 -*-
module PivotalButler
  class Story
    class << self
      def nick(story)
        name = story.owned_by
        if name
          PivotalButler::Setting.pivotal_tracker.nickname[name] || name
        else
          '未設定'
        end
      end

      def id(story)
        "#" + story.id.to_s
      end

      def type(story)
        story.story_type
      end

      def state(story)
        story.current_state
      end

      def story(story)
        story.name
      end

      def url(story)
        story.url
      end
    end
  end
end
