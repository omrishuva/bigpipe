require "spec_helper"

class Book < Entity
	
end

RSpec.describe Entity do
  
  it "requires a title" do
    expect(Book.new title: nil).not_to be_valid
    expect(Book.new title: "title").to be_valid
  end

end
