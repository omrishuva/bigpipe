class Activity < Entity
  
  DEPRECATED_FIELDS = [:location_coordinates, :user_id]

	attr_accessor :id, :state, :account_id, :activity_type, :title, :locale, :gender, :cover_image_id, :about_text, :location, :place_id, :categories, :tags, :levels, :max_guest_limit, :duration, :price, :scheduling_configuration, :created_by, :owner_id, :created_at, :updated_at
  
  before_save :set_default_state, unless: :has_state?

	def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
  	super( params )
  end
  
  def owners
  	[user_id, owner_id ].uniq.compact
  end

  def cover_image
    cover_image_id || "https://placehold.it/700x400"
  end
  
  def self.metadata
    @@metadata =  YAML.load_file("./lib/activity_metadata.yaml")
  end
  
  def account
    @account ||= Account.find( account_id.to_s )
  end

  def account_public_info_completed?
    ![account.public_info[:text].present?, account.public_info[:image].present?].uniq.include?( false )
  end
  
  def save_scheduling_configuration( params )
    case params[:schedulingType]
      when "specificDates"  then scheduling_configuration_item =  "specificDates_#{DateTime.parse( params[:selectedDate] )}_#{params[:activityLeader]}"
      when "specificDates"  then scheduling_configuration_item =  "specificDates_#{DateTime.parse( params[:selectedDate] )}_#{params[:activityLeader]}"
      when "recurringEvent" then scheduling_configuration_item =  "recurringEvent_#{params[:selectedDayOfWeek]}@#{params[:selectedTime]}_#{params[:activityLeader]}"
    end 

    if scheduling_configuration.present? 
      self.scheduling_configuration << scheduling_configuration_item
      self.scheduling_configuration.uniq!
      self.scheduling_configuration.compact!
      self.save
    else
      self.update( scheduling_configuration: [ scheduling_configuration_item ] )
    end

  end

  def set_default_state
    self.state = "draft"
  end

  def has_state?
    self.state.present?
  end

end