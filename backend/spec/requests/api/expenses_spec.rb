require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  describe "GET /api/expenses" do
    it "returns all expenses with category information" do
      Expense.create!(description: "Lunch", amount: 100.00, category: food_category, date: Date.today)
      Expense.create!(description: "Taxi", amount: 50.00, category: transport_category, date: Date.today)

      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it "returns expenses in descending order by date" do
      older_expense = Expense.create!(
        description: "July 1 lunch",
        amount: 100.00,
        category: food_category,
        date: Date.new(2026, 7, 1)
      )
      newer_expense = Expense.create!(
        description: "July 8 lunch",
        amount: 50.00,
        category: transport_category,
        date: Date.new(2026, 7, 8)
      )

      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(newer_expense.id)
      expect(json.last["id"]).to eq(older_expense.id)
    end

    it "places a newly created expense with today's date near the top" do
      old_expense = Expense.create!(
        description: "Old expense",
        amount: 25.00,
        category: food_category,
        date: Date.new(2024, 1, 1)
      )
      today_expense = Expense.create!(
        description: "Today's expense",
        amount: 75.00,
        category: transport_category,
        date: Date.today
      )

      get "/api/expenses"

      json = JSON.parse(response.body)
      today_index = json.index { |expense| expense["id"] == today_expense.id }
      old_index = json.index { |expense| expense["id"] == old_expense.id }

      expect(today_index).to be < old_index
      expect(today_index).to eq(0)
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq(150.5)
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
