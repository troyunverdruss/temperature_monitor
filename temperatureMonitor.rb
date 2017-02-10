#!/usr/bin/env ruby

require 'sqlite3'
require 'optparse'
require 'fileutils'
require 'yaml'
require 'mysql2'

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: ./temperatureMonitor.rb'

  opts.on '-r', '--read', 'Read sensors' do |o|
    options[:read] = true
  end

  opts.on '-u', '--upload', 'Upload data' do |o|
    options[:upload] = true
  end

  opts.on '-c', '--clean', 'Clean local DB' do |o|
    options[:clean] = true
  end
end.parse!

DATABASE_NAME = 'temperature.db'

if File.exist? DATABASE_NAME
  db = SQLite3::Database.open DATABASE_NAME
else
  db = SQLite3::Database.new DATABASE_NAME
  db.execute <<-SQL
  CREATE TABLE data (
    sensor_id VARCHAR(255),
    epoch_timestamp INT,
    temp_reading REAL,
    uploaded INT
  );
  SQL
end


if options[:read]
  reading=`digitemp_DS9097U  -a -o "%R:%.2F" -q`
  reading.split(/\n/).each do |line|
    sensor, temp = line.split(':')
    puts 'reading: ' + sensor + temp
    db.execute 'INSERT INTO data VALUES (?, ?, ?, ?)', [sensor, Time.now.to_i, temp, 0]
  end
end

if options[:upload]
  config = YAML::load_file 'config.yaml'
  c = config['db']
  client = Mysql2::Client.new(
      :host => c['host'],
      :username => c['user'],
      :password => c['pass'],
      :port => c['port'],
      :database => c['name']
  )



end

if options[:clean]
  db.execute 'DELETE FROM data WHERE uploaded = ?', 1
end