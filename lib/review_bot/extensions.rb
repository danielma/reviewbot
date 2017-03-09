class Time
  def round_to(interval)
    self.class.at((to_f / interval).round * interval).utc
  end
end
