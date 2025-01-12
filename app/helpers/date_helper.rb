module DateHelper

  def time_ago_in_specific_words(from_time, type)
    if type == :short
      scope = :'datetime.distance_in_short_words'
    else
      scope = :'datetime.distance_in_words'
    end

    options = {}
    to_time = Time.now

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    I18n.with_options :locale => options[:locale], :scope => scope do |locale|
      case distance_in_minutes
        when 0..1
          case distance_in_seconds
            when 0..59       then locale.t(:x_seconds,      :count => distance_in_seconds) + " " + locale.t(:ago, :scope => "questions")
            else                  locale.t(:x_minutes,      :count => 1) + " " + locale.t(:ago, :scope => "questions")
          end
        when 2..59           then locale.t(:x_minutes,      :count => distance_in_minutes) + " " + locale.t(:ago, :scope => "questions")
        when 60..1439        then locale.t(:x_hours,        :count => (distance_in_minutes.to_f / 60.0).round) + " " + locale.t(:ago, :scope => "questions")
        when 1440..7199      then locale.t(:x_days,         :count => (distance_in_minutes.to_f / 1440.0).round) + " " + locale.t(:ago, :scope => "questions")
        else
          if from_time.year != Time.now.year
            locale.l from_time, :scope => :'', :format => :semishort_with_year, :locale => :pl_strict
          else
            locale.l from_time, :scope => :'', :format => :semishort, :locale => :pl_strict
          end
      end
    end
  end

  # Alternative version of standard time_ago_in_words (shorter output)
  def time_ago_in_short_words(from_time)
    time_ago_in_specific_words(from_time, :short)
  end

  # Alternative version of standard time_ago_in_words (full output)
  def time_ago_in_full_words(from_time)
    time_ago_in_specific_words(from_time, :full)
  end

end