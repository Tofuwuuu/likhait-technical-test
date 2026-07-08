require 'rails_helper'

RSpec.describe "Api::Categories", type: :request do
  describe "GET /api/categories" do
    let!(:food) { Category.create!(name: "Food") }
    let!(:transport) { Category.create!(name: "Transport") }
    let!(:supplies) { Category.create!(name: "Supplies") }

    it "returns all categories" do
      get "/api/categories"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.map { |c| c["name"] }).to include("Food", "Transport", "Supplies")
    end

    it "returns categories in alphabetical order" do
      get "/api/categories"

      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to eq([ "Food", "Supplies", "Transport" ])
    end

    it "includes newly created categories in the list" do
      post "/api/categories", params: { category: { name: "Groceries", emoji: "🛒" } }, as: :json

      get "/api/categories"

      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to include("Groceries")
    end
  end

  describe "POST /api/categories" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          category: {
            name: "Groceries",
            emoji: "🛒"
          }
        }
      end

      it "creates a new category" do
        expect {
          post "/api/categories", params: valid_params, as: :json
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Groceries")
        expect(json["emoji"]).to eq("🛒")
      end

      it "creates a category without an emoji" do
        post "/api/categories", params: { category: { name: "Miscellaneous" } }, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Miscellaneous")
        expect(json["emoji"]).to be_nil
      end
    end

    context "with invalid parameters" do
      it "rejects a duplicate name" do
        Category.create!(name: "Groceries", emoji: "🛒")

        expect {
          post "/api/categories", params: { category: { name: "Groceries" } }, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name has already been taken")
      end

      it "rejects a duplicate name regardless of case" do
        Category.create!(name: "Groceries")

        post "/api/categories", params: { category: { name: "groceries" } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "rejects a blank name" do
        expect {
          post "/api/categories", params: { category: { name: "" } }, as: :json
        }.not_to change(Category, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name can't be blank")
      end
    end
  end
end
