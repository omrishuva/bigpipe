def get_widget_names
  base_path = "./app/views/widgets/"
  multiple_state_path = "#{base_path}/multiple_state"
  wizard_path = "#{base_path}/wizard"
  multiple_state =  Dir.entries(multiple_state_path).select { |file| File.directory? File.join(multiple_state_path, file)}
  wizard =  Dir.entries(wizard_path).select { |file| File.directory? File.join(wizard_path, file)}
  { multiple_state: multiple_state, wizard: wizard  }
end

$widget_names = get_widget_names