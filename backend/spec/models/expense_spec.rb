require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:category) { Category.create!(name: "Food") }

  it "is valid with a past date" do
    expense = described_class.new(
      description: "Lunch",
      amount: 100.00,
      category: category,
      date: Date.yesterday
    )

    expect(expense).to be_valid
  end

  it "is valid with today's date" do
    expense = described_class.new(
      description: "Lunch",
      amount: 100.00,
      category: category,
      date: Date.current
    )

    expect(expense).to be_valid
  end

  it "is invalid with a future date" do
    expense = described_class.new(
      description: "Lunch",
      amount: 100.00,
      category: category,
      date: Date.tomorrow
    )

    expect(expense).not_to be_valid
    expect(expense.errors[:base]).to include("Expense date cannot be in the future")
  end
end
