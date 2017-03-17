module ReviewBot
  class Reviewer < OpenStruct
    def work_hours_between(start_time, end_time)
      HourOfDay.work_hours_between(start_time, end_time, timezone)
    end

    def timezone
      Timezone[@table[:timezone]]
    end

    def work_hour?
      HourOfDay.new(timezone.utc_to_local Time.now.utc).work_hour?
    end
  end
end
