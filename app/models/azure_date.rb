class AzureDate < SecondBase::Base
  before_save :set_params

  def set_params
    self.description = self.date.to_formatted_s(:short)
    self.minute = self.date.strftime('%M').to_i
    self.hour = self.date.strftime('%H').to_i
    self.day = self.date.strftime('%d').to_i
    self.day_of_the_week = self.date.strftime('%A')
    self.day_of_the_year = self.date.strftime('%j').to_i
    self.week_of_the_year = self.date.strftime('%W').to_i
    self.month = self.date.strftime('%B')
    self.year = self.date.strftime('%Y').to_i
  end

end