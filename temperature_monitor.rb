#!/usr/bin/env ruby

require 'fileutils'
require 'yaml'
require 'pg'
require 'pathname'

# CREATE TABLE temperature_readings.readings (
#     id SERIAL PRIMARY KEY,
#     sensor_id VARCHAR(32) NOT NULL,
#     timestamp TIMESTAMP NOT NULL,
#     temp_reading DOUBLE PRECISION NOT NULL
# )


script_path = File.expand_path File.dirname(__FILE__)

config = YAML::load_file script_path + '/config.yaml'
c = config['db']

reading = `digitemp_DS9097U -a -o "%R:%.2F" -q`
reading.split(/\n/).each do |line|
  sensor, temp = line.split(':')
  puts 'reading: ' + sensor + temp

  begin
    connection = PG.connect(
      {
        user: c['user'],
        password: c['pass'],
        dbname: c['name'],
        host: c['host'],
        port: c['port'],
      }
    )

    connection.exec(
      "INSERT INTO readings (sensor_id, temp_reading) VALUES ($1, $2)",
      [sensor, temp]
    )

  ensure
    connection.finish
  end
end


