module Shapado
  module Controllers
    module Utils
      def self.included(base)
        base.class_eval do
          helper_method :page_title, :feed_urls, :is_bot?, :current_tags
        end
      end

      def current_tags
        @current_tags ||=  if params[:tags].kind_of?(String)
          params[:tags].split("+")
        elsif params[:tags].kind_of?(Array)
          params[:tags]
        else
          []
        end
      end

      def set_page_title(title)
        @page_title = title
      end

      def page_title
        if @page_title
            "#{@page_title} - #{t("layouts.application.title")}"
        else
            "#{t("layouts.application.title_long")}"
        end
      end

      def feed_urls
        @feed_urls ||= Set.new
      end

      def add_feeds_url(url, title="atom")
        feed_urls << [title, url]
      end

      def is_bot?
        request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|Java|Yandex|Linguee|LWP::Simple|Exabot|ia_archiver|Purebot|Twiceler|StatusNet|Baiduspider)\b/i
      end

      def build_date(params, name)
        Time.zone.parse("#{params["#{name}(1i)"]}-#{params["#{name}(2i)"]}-#{params["#{name}(3i)"]}") rescue nil
      end

      def build_datetime(params, name)
        Time.zone.parse("#{params["#{name}(1i)"]}-#{params["#{name}(2i)"]}-#{params["#{name}(3i)"]} #{params["#{name}(4i)"]}:#{params["#{name}(5i)"]}") rescue nil
      end
    end
  end
end
