#!/usr/bin/ruby
#
#
#

def getProcessList(mysql = nil)
  if ! mysql.nil? 
    query = 'show full processlist'
    return mysql.query(query)
  end

  cmd = "mysql -h 127.0.0.1 -u root -e 'show processlist;' | grep -v Sleep"
  #return `#{cmd}`.lines.map { |x| x.split("\t")}

  processList = []

  lines = `#{cmd}`.lines.map { |x| x.split("\t")}

  # turn each line into an array of hashes
  lines.drop(1).each_with_index do |line, i|
    processList[i] = {}
    line.each_with_index do |col, n|
      processList[i][lines.first[n]] = col
    end
  end

  return processList

  #`#{cmd}`.lines.map do |line, i|
  #  line.split("\t").map do |column, n|
  #    processList[i].push({ lines.map.first[n] => n})
  #  end
  #end
end

def findLongProcess(processList)
  processList.each do |p|
    ['Time'].class
    if p['State'] == 'Sleep'
      next
    end

    if p['Time'].to_i > 600
      puts "AWOOGA - process #{p['Id']} by user #{p['User']} has been running for #{p['Time']}"
    end

  end
end

p = getProcessList

findLongProcess(p)
