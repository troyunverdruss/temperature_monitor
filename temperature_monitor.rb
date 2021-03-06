#!/usr/bin/env ruby

require 'sqlite3'
require 'optparse'
require 'fileutils'
require 'yaml'
require 'mysql'
require 'pathname'

script_path = File.expand_path File.dirname(__FILE__)

DATABASE_NAME = script_path.to_s + '/temperature.db'

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: ./temperature_monitor.rb'

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
  config = YAML::load_file script_path + '/config.yaml'
  c = config['db']
  begin
    connection = Mysql.connect(c['host'], c['user'], c['pass'], c['name'], c['port'])

    db.execute('SELECT rowid, sensor_id, epoch_timestamp, temp_reading FROM data WHERE uploaded = 0') do |row|
      prepared_statement = connection.prepare 'INSERT INTO data (sensor_id, epoch_timestamp, temp_reading) VALUES (?, ?, ?)'
      prepared_statement.execute row[1], row[2], row[3]
      db.execute 'UPDATE data SET uploaded = ? WHERE rowid = ?', [1, row[0]]
    end
  ensure
    connection.close if connection
  end
end

if options[:clean]
  db.execute 'DELETE FROM data WHERE uploaded = ?', 1
end