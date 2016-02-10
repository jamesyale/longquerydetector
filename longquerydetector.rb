#!/usr/bin/ruby
#
#
#
#require 'mysql2'
#
def getMySQL
  begin
    client = Mysql2::Client.new(:host => 'localhost', :username => 's3-to-ceph', :password =>      'NodhafmetIchoknyajianauquecisJonVekpaudd')
    return client
  rescue => e
    puts "Waiting for MySQL connection, error: #{e}"
    sleep 1 + rand
  retry
  end
end

def getProcessList(mysql = nil)
  if ! mysql.nil? 
    query = 'show full processlist'
    return mysql.query(query)
  end

  cmd = "mysql -h 127.0.0.1 -u root -e 'show processlist;' | grep -v Sleep"
  return `#{cmd}`.lines.map { |x| x.split("\t")}
end

result = getProcessList

puts result[1]

