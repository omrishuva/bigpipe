require "spec_helper"
RSpec.describe Entity do
	
	before :all do
		class Book < Entity
		  attr_accessor :id, :title, :author, :published_on, :description, :created_at, :updated_at
	  	validates :title, presence: true
	  end
	  Book.destroy_all
  	@valid_params = { title: "stam", author: "Japp Stam", published_on: Time.now.to_date, description: "mamash stam" }
  	@invalid_params = { author: "Japp Stam", published_on: Time.now.to_date, description: "mamash stam" }
	end

  it "should create a new entity" do
  	entities_number_before = Book.all.size
  	Book.create( @valid_params  )
  	entities_number_after = Book.all.size
  	expect(entities_number_before).to eq( entities_number_after - 1)
	 end
	
	it "should add a created_at attributes for new entities" do
		Book.create(@valid_params)
		expect(Book.last.created_at).to_not be nil
	end
	
	it "should not override the created_at when updating an entity" do
		book_object = Book.new(@valid_params)
		book_object.save
		expect(Book.last.created_at).to eq(book_object.created_at)
	end

	it "should not create an entity with invalid params" do
		expect( Book.create(@invalid_params) ).to be false
	end
  
  it "should not save a ruby object as a datastore entity if one not valid" do
  	book_object = Book.new(@invalid_params)
		expect( book_object.save ).to be false
	end
  
  it "should find an exisiting entity" do
  	book = Book.last
 		expect( Book.find(book.id).id ).to eq book.id
  end
  
  it "should update entity attributes" do
  	book = Book.last
  	book.update(title: "ze mamash stam")
  	expect( Book.last.title ).to eq "ze mamash stam"
  end
  
  it "should create entities with a namespace matching to the environment" do
  	expect( Book.last(raw: true).key.namespace ).to eq Rails.env
  end
  
  it "should mark saved entities as persisted" do
  	book = Book.new(@valid_params)
  	book.save
  	expect( book.persisted? ).to be true
  end

  it "should mark unsaved entities as not persisted" do
  	book = Book.new(@valid_params)
  	expect( book.persisted? ).to be false
  end

end
