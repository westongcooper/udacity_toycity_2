require 'json'
require_relative "../support/ascii.rb"

def create_output_file
  file_name = ARGV[0] || 'report.txt'
  $> = File.new(file_name, 'w')
  $>.sync = true
end

def parse_products_json
  path = File.join(File.dirname(__FILE__), '../data/products.json')
  file = File.read(path)
  JSON.parse(file)
end

def output_header
  Ascii.sales_report
  output_todays_date
end

def output_todays_date
  puts "Date: " + Time.new.strftime("%B %d, %Y")
end

def output_products products_hash
  Ascii.products
  products_hash["items"].each do |item|
    total_item_sales = 0
    sales_count = item['purchases'].count

    puts "Name: #{item['title']}"
    puts "Retail price: $#{item['full-price']}"
    puts "Number of purchases: #{sales_count}"

    item['purchases'].each do |sale|
      total_item_sales += sale["price"]
    end

    average_sale_price = total_item_sales / sales_count
    average_discount_percent = (1 - (average_sale_price / item['full-price'].to_f)) * 100

    puts "Total sales amount: $#{total_item_sales}"
    puts "Average price of each product: $#{average_sale_price}"
    puts "Average discount: #{average_discount_percent.round(1)}%"
    puts "\n"
  end
end

def output_brands brands
  Ascii.brands

  brands.each do |brand,toys|
    brand_toys_total_cost = brand_revenue = 0

    puts "Brand: #{brand}"
    puts "Number of Toys: #{toys.count}"

    toys.each do |toy|
      brand_toys_total_cost += toy["full-price"].to_f
      toy["purchases"].each do |sale|
        brand_revenue += sale["price"]
      end
    end

    average_price = brand_toys_total_cost / toys.count

    puts "Average price of each toy: $#{average_price.round(2)}"
    puts "Total revenue of all toys: $#{brand_revenue.round(2)}"
    puts "\n"
  end
end

def convert_to_brands_hash products_hash
  brands = {}
  products_hash["items"].each { |item| (brands[item["brand"]] ||= []) << item }
  brands
end

def start
  create_output_file
  output_header
  products_hash = parse_products_json
  output_products(products_hash)
  brands_hash = convert_to_brands_hash(products_hash)
  output_brands(brands_hash)
end

start
