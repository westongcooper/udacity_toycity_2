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
    sales_count = item['purchases'].count
    total_item_sales = tally_hash_from_array(item['purchases'], 'price')
    average_sale_price = total_item_sales / sales_count
    ave_discount_percent = discount_percent(average_sale_price, item['full-price'].to_f)

    puts "Name: #{item['title']}"
    puts "Retail price: $#{item['full-price']}"
    puts "Number of purchases: #{sales_count}"
    puts "Total sales amount: $#{total_item_sales}"
    puts "Average price of each product: $#{average_sale_price}"
    puts "Average discount: #{ave_discount_percent.round(1)}%"
    puts "\n"
  end
end

def discount_percent sale_price, full_price
  (1 - (sale_price / full_price)) * 100
end

def output_brands brands
  Ascii.brands
  brands.each do |brand,toys|
    brand_toys_total_value = tally_hash_from_array(toys, 'full-price')
    brand_revenue = calculate_revenue(toys)
    average_price = brand_toys_total_value / toys.count

    puts "Brand: #{brand}"
    puts "Number of Toys: #{toys.count}"
    puts "Average price of each toy: $#{average_price.round(2)}"
    puts "Total revenue of all toys: $#{brand_revenue.round(2)}"
    puts "\n"
  end
end

def sum_array array
  array.inject(0){|sum,x| sum + x }
end

def tally_hash_from_array array, context
  sum_array(array.map { |hash| hash[context].to_f })
end

def calculate_revenue toys
  sum_array(toys.map {|toy| tally_hash_from_array(toy['purchases'], 'price')})
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
