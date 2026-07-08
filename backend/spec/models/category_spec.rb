require 'rails_helper'

RSpec.describe Category, type: :model do
  it "is valid with a name" do
    category = Category.new(name: "Groceries", emoji: "🛒")
    expect(category).to be_valid
  end

  it "is invalid without a name" do
    category = Category.new(name: nil)
    expect(category).not_to be_valid
    expect(category.errors[:name]).to include("can't be blank")
  end

  it "is invalid with a duplicate name" do
    Category.create!(name: "Groceries")
    duplicate = Category.new(name: "Groceries")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to include("has already been taken")
  end

  it "is invalid with a duplicate name regardless of case" do
    Category.create!(name: "Groceries")
    duplicate = Category.new(name: "GROCERIES")

    expect(duplicate).not_to be_valid
  end

  it "is valid without an emoji" do
    category = Category.new(name: "Groceries", emoji: nil)
    expect(category).to be_valid
  end
end
