module ApplicationHelper

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", info: "alert-info" }[flash_type.to_sym]
  end
  
  def profile_pic_src
  	current_user.try(:profile_picture).present? ? current_user.profile_picture : 'genderless_silhouette.png'
  end

end