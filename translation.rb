table "customers" do
  column "id", :key
  column "name", :string
  column "birth_date", :date
  column "phone", :string
  column "mobile", :string
  column "other_phone", :string
  column "email", :string
  column "other_email", :string
  column "address", :string
  column "whom_to_contact", :string
end

table "customer_cars" do
  column "id", :key
  column "customer_id", :integer, :references => :customers
  column "registration_no", :string
  column "registration_date", :date
  column "manufacturing_month", :integer
  column "manufacturing_year", :integer
  column "engine_no", :string
  column "chasis_no", :string
  column "color", :string
end