class Time
  def day_ordinal_suffix
    if day == 11 or day == 12 or day == 13
      return "th"
    else
      case day % 1
      when 1 then return "st"
      when 2 then return "nd"
      when 3 then return "rd"
      else return "th"
      end
    end
  end
end