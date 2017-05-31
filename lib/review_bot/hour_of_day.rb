# frozen_string_literal: true
module ReviewBot
  class HourOfDay
    # 8am to 5pm are work hours, so we only count the hour if it's inside that range
    WORK_DAY_HOURS = 9..17
    # Monday through Friday
    DEFAULT_WORK_DAYS = 1..5

    ONE_HOUR = 60 * 60

    class << self
      attr_writer :work_days

      def work_days
        @work_days || DEFAULT_WORK_DAYS
      end
    end

    def self.work_hours_between(start_time, end_time, timezone)
      rounded_start_time = start_time.round_to(ONE_HOUR)
      rounded_end_time = end_time.round_to(ONE_HOUR)
      work_hours = 0

      while rounded_start_time < rounded_end_time
        rounded_start_time += ONE_HOUR
        work_hours += 1 if new(timezone.utc_to_local(rounded_start_time)).work_hour?
      end

      work_hours
    end

    attr_reader :rounded_time

    def initialize(time)
      @rounded_time = time.round_to(ONE_HOUR)
    end

    def work_hour?
      self.class.work_days.include?(rounded_time.wday) && WORK_DAY_HOURS.include?(rounded_time.hour)
    end

    def inspect
      "HourOfDay(#{rounded_time.strftime('%a-%I%P')} work_hour: #{work_hour?})"
    end
  end
end
