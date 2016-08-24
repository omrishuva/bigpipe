require "spec_helper"

RSpec.describe WidgetsController do
  
  after :all do
    User.destroy_all
  end

  describe "base_widget" do
    
    before :each do
      User.destroy_all
      @user = User.new(  name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play" )
      @user.save
      @widget_data = {
                      widgetName: "text_area_box",
                      elementName: "textAreaBox",
                      objectName: "users",
                      objectId: @user.id,
                      key: "about_text",
                      placeholder: "name_it",
                      placeholderClass: "textArea",
                      textClass: "ltrimageOverlayText activityTitle",
                      buttonClass: "imageOveralyButton",
                      state: "edit",
                      maxValue: nil,
                      sliderSteps: nil
                    }
    end

    it "should assign isWidgetOwner to true when the user is the owner" do
      controller.stub(:current_user).and_return(@user)
      xhr :get, "multiple_state_widget_control", @widget_data
      @widget_data.merge!( editableOverlayText: nil, isWidgetOwner: true, value: @user.about_text, dataType: nil, maxSelections: nil, selectOptions: nil  )
      expect( assigns(:widget_data) ).to eq @widget_data 
    end

     it "should assign isWidgetOwner to true when the user is super_admin" do
      @admin = User.new(  name: "omri shuva", email: "omri@gmail.com", phone: "0526733430", password: "zzzaaaa123", auth_provider: "play" )
      @admin.save
      sleep 1
      @admin.make_super_admin
      controller.stub(:current_user).and_return( @admin )
      xhr :get, "multiple_state_widget_control", @widget_data
      @widget_data.merge!( editableOverlayText: nil, isWidgetOwner: true, value: @user.about_text, dataType: nil, maxSelections: nil, selectOptions: nil  )
      expect( assigns(:widget_data) ).to eq @widget_data 
    end
        
    it "should update the correct entity and field according to widget data" do
      controller.stub(:current_user).and_return(@user)
      @widget_data[:state] = "save"
      @widget_data[:data] = "about text"
      xhr :post, "multiple_state_widget_control", @widget_data
      @widget_data.merge!( editableOverlayText: nil, isWidgetOwner: true, value: @user.about_text, dataType: nil, maxSelections: nil, selectOptions: nil  )
      expect( @user.about_text ).to eq "about text"  
    end


  end

  describe "image_widget" do
     
     before :each do
      User.destroy_all
      @user = User.new(  name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play" )
      @user.save
      account = Account.create_freelancer_account( @user )
      @activity = Activity.new( account_id: account.id, title: "Untitled Activity" )
      @activity.save
      test_photo = ActionDispatch::Http::UploadedFile.new({
        :filename => 'test_photo_1.jpg',
        :type => 'image/jpeg',
        :tempfile => File.new("#{Rails.root}/spec/fixtures/example.jpg")
      })
      
      @widget_data = {
                        image: test_photo,
                        widget: "{\"nestedWidgetSelectorKey\":\"#5685925472370688.widgetControl[data-element-name='textInputBox'][data-key='title']\",\"widgetName\":\"image_box\",\"elementName\":\"imageBox\",\"objectName\":\"activities\",\"objectId\":\"#{@activity.id}\",\"key\":\"cover_image_id\",\"placeholder\":\"update_image\",\"overlayText\":\"{\\\"enabled\\\":true,\\\"key\\\":\\\"title\\\",\\\"value\\\":\\\"Street Art Tour\\\",\\\"objectName\\\":\\\"activities\\\",\\\"objectId\\\":#{@activity.id},\\\"state\\\":null,\\\"isWidgetOwner\\\":true,\\\"placeholder\\\":\\\"name_it\\\",\\\"textClass\\\":\\\"ltrimageOverlayText activityTitle\\\",\\\"buttonClass\\\":\\\"imageOveralyButton\\\"}\",\"editableOverlayText\":\"\",\"imageWidth\":\"770\",\"imageHeight\":\"430\",\"imageCrop\":\"fill\",\"imageGravity\":\"center\",\"imageTagClass\":\"coverImage img-fluid\",\"imageTagId\":\"\"}",
                        widgetName: "image_box",
                        objectName: "activities",
                        key: "cover_image_id"
                      }
    end

    after :each do
      Cloudinary::Uploader.destroy( @activity.reload!.cover_image_id )
    end
   
    it "should assign isWidgetOwner to true when the user is the owner" do
      controller.stub(:current_user).and_return( @user )
      xhr :post, "multiple_state_widget_control", @widget_data
      expect( assigns(:widget_data) ).to eq ( {:widgetName=>"image_box", :elementName=>"imageBox", :objectName=>"activities", :objectId=>@activity.id, :key=>"cover_image_id", :value=>  @activity.reload!.cover_image_id, :imageWidth=>"770", :imageHeight=>"430", :imageCrop=>"fill", :imageGravity=>"center", :imageTagClass=>"coverImage img-fluid", :imageTagId=>"", :isWidgetOwner=>true, :overlayText=>{"enabled"=>true, "key"=>"title", "value"=>"Street Art Tour", "objectName"=>"activities", "objectId"=>@activity.id, "state"=>nil, "isWidgetOwner"=>true, "placeholder"=>"name_it", "textClass"=>"ltrimageOverlayText activityTitle", "buttonClass"=>"imageOveralyButton"}, :placeholder=>"update_image", :editableOverlayText=>""} )
    end

     it "should assign isWidgetOwner to true when the user is admin" do
      @admin = User.new(  name: "omri shuva", email: "omri@gmail.com", phone: "0526733430", password: "zzzaaaa123", auth_provider: "play" )
      @admin.save
      sleep 1
      @admin.make_super_admin
      controller.stub(:current_user).and_return( @user )
      xhr :post, "multiple_state_widget_control", @widget_data
      expect( assigns(:widget_data) ).to eq ( {:widgetName=>"image_box", :elementName=>"imageBox", :objectName=>"activities", :objectId=>@activity.id, :key=>"cover_image_id", :value=>  @activity.reload!.cover_image_id, :imageWidth=>"770", :imageHeight=>"430", :imageCrop=>"fill", :imageGravity=>"center", :imageTagClass=>"coverImage img-fluid", :imageTagId=>"", :isWidgetOwner=>true, :overlayText=>{"enabled"=>true, "key"=>"title", "value"=>"Street Art Tour", "objectName"=>"activities", "objectId"=>@activity.id, "state"=>nil, "isWidgetOwner"=>true, "placeholder"=>"name_it", "textClass"=>"ltrimageOverlayText activityTitle", "buttonClass"=>"imageOveralyButton"}, :placeholder=>"update_image", :editableOverlayText=>""} )
    end

    it "should update the correct entity and field according to widget data" do
      controller.stub(:current_user).and_return( @user )
      xhr :post, "multiple_state_widget_control", @widget_data
      expect( @activity.reload!.cover_image_id ).to_not be nil
    end    

  end

end