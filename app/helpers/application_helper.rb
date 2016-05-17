module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", info: "alert-info" }[flash_type.to_sym]
  end
end