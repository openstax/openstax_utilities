module OpenStax::Utilities::Helpers
  module Datetime

    def standard_date(datetime)
      datetime.nil? ? 
        "" : 
        datetime.strftime(OSU.configuration.standard_date_format)
    end
    
    def standard_datetime(datetime)
      datetime.nil? ? 
        "" : 
        datetime.strftime(OSU.configuration.standard_datetime_format)
    end
    
    def standard_time(datetime)
      datetime.nil? ? 
        "" : 
        datetime.strftime(OSU.configuration.standard_time_format)
    end
    
    def standard_datetime_zone(datetime, zone)
      datetime.nil? ? 
        "" : 
        datetime.in_time_zone(zone).strftime(OSU.configuration.standard_datetime_format)
    end
    
    def month_year(datetime)
      datetime.nil? ? "" : datetime.strftime("%B %Y")
    end

  end
end