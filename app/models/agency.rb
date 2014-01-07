class Agency < ActiveRecord::Base
  attr_accessible :name, :recipients, :password
  
  belongs_to :password_list
  
  validates_presence_of :name
  validates_presence_of :recipients
  validates_presence_of :password
  
  def recipients
    r = read_attribute(:recipients)
    r.split(",").join(", ") unless r.nil?
  end
  
  def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      order("name ASC")
    end
  end
  
end
