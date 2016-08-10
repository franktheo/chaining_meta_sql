require 'mysql'

class WaterSample
  
  #start connection to mysql server, fetch table headers and row contents
  def self.find(sample_id)
    begin
      @con = Mysql.real_connect("localhost", "frank", "abcdefghi", "my_db")
      @rs_id = @con.query("SELECT * FROM water_samples WHERE id = #{sample_id}")
      @rs_fields = @rs_id.fetch_fields
      @rs =  @rs_id.fetch_row
      self
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    end
  end

  #implementing site, choloroform, ..., dibromochloromethane method
  class << self
    ["site", "chloroform", "bromoform", "bromodichloromethane", "dibromichloromethane"].each_with_index do |k,index|
      define_method("#{k}") do        
        (index+1) == 1 ? @rs[index+1] : @rs[index+1].to_f
      end
    end
  end

  #i.e. factor = @rs[2].to_f * wf[1].to_f + @rs[3].to_f * wf[2].to_f + @rs[4].to_f * wf[3].to_f + @rs[5].to_f * wf[4].to_f
  def self.calculate_factor(wf)
    factor = 0
    for i in 1..(wf.size-1)
      factor += @rs[i+1].to_f*wf[i].to_f
    end
    factor
  end

  #get factor as a linear combination of factor weights and row contents
  def self.factor(factor_weights_id)
    rs_wf_id = @con.query("SELECT * FROM factor_weights WHERE id = #{factor_weights_id}")
    wf = rs_wf_id.fetch_row

    if wf == nil
      puts "No factor weight id in the database. Please enter a valid one"
      return
    end

    calculate_factor(wf)
  end

  #get existing factors
  def self.factor_group
    rs_wf = @con.query("SELECT * FROM factor_weights")
    no_rows = rs_wf.num_rows

    @hash_factor = {}
    no_rows.times do
      wf = rs_wf.fetch_row
      
      factor = calculate_factor(wf)

      if factor != 0
        factor_id = "factor_#{wf[0]}".to_sym
        @hash_factor[factor_id] = factor
      end      
    end
  end

  #collecting hash key and value
  def self.get_hash
    @hash = {}
    @hash[@rs_fields[0].name.to_sym] = @rs[0].to_i
    @hash[@rs_fields[1].name.to_sym] = @rs[1]
    for i in 2..(@rs_fields.size-1)
      @hash[@rs_fields[i].name.to_sym] =  @rs[i].to_f
    end
    @hash
  end

  #get data in a hash format
  def self.to_hash(include_factors = false)
    if include_factors == true
      get_hash
      factor_group
      @hash.merge(@hash_factor)
    else
      get_hash
    end
  end

  def self.close_connection
     @con.close if @con
  end
end

sample2 = WaterSample.find(2)

=begin
puts "test"
puts sample2.site1
puts sample2.chloroform1
puts sample2.bromoform1
puts sample2.bromodichloromethane1
puts sample2.dibromichloromethane1
=end

if sample2 != nil

  puts "Site name and collected trihalomethane values:"
  puts "Site: " + sample2.site.inspect
  puts "Chloroform value: " + sample2.chloroform.inspect
  puts "Bromoform value: " + sample2.bromoform.inspect
  puts "Bromodichloromethane value: " + sample2.bromodichloromethane.inspect
  puts "Dibromichloromethane value: " + sample2.dibromichloromethane.inspect

  puts "----- "
  puts "Factor: " + sample2.factor(4).inspect

  puts "----- "
  puts "Data in hash format:"
  puts sample2.to_hash
  puts sample2.to_hash(true)

  WaterSample.close_connection
end

require "rspec/autorun"

RSpec.describe WaterSample do

  it "test water sample" do

    sample2 = WaterSample.find(2)
    
    expect(sample2.site).to eq("North Hollywood Pump Station (well blend)")
    expect(sample2.chloroform).to eq(0.00291)
    expect(sample2.bromoform).to eq(0.00487)
    expect(sample2.bromodichloromethane).to eq(0.00547)
    expect(sample2.dibromichloromethane).to eq(0.0109)
  end

  it "test factor weight" do

    sample2 = WaterSample.find(2)
    expect(sample2.factor(2)).to eq(0.02415)
    expect(sample2.to_hash).to eq({:id=>2, :site=>"North Hollywood Pump Station (well blend)", :chloroform=>0.00291, :bromoform=>0.00487, :bromodichloromethane=>0.00547, :dibromichloromethane=>0.0109})
    expect(sample2.to_hash(true)).to eq({:id=>2, :site=>"North Hollywood Pump Station (well blend)", :chloroform=>0.00291, :bromoform=>0.00487, :bromodichloromethane=>0.00547, :dibromichloromethane=>0.0109, :factor_1=>0.024007, :factor_2=>0.02415, :factor_3=>0.021627, :factor_4=>0.02887})
   end

end
