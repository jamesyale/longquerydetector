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
  badQueries = []

  processList.each do |p|
    if p['State'] == 'Sleep'
      next
    end

    if p['Info'].downcase.include?('select')
      next
    end

    if p['Time'].to_i > $config['timeout']
      badQueries.push(p)
    end
  end
  return badQueries
end

def sendToSlack(msg, channel = 'infraops-alerts')
  command = "curl --data '#{msg}' 'https://livelink.slack.com/services/hooks/slackbot?token=wM0DB3lCIFTGHzr04PgIGHgr&channel=%23#{channel}'"
  system(command)
end

def reportQueries(q)
  q.each do |p|
    main = "AWOOGA - process #{p['Id']} by user #{p['User']} on #{p['Host']} has been running for #{p['Time']} seconds @jamesyale"
    info = "Full query: `#{p['Info']}`"
    puts main, info
    sendToSlack("#{main}\n#{info}")
  end
end

#$config = { 'timeout' => 600 }
$config = { 'timeout' => 60 }

p = getProcessList

if findLongProcess(p).length > 0
  reportQueries(findLongProcess(p))
end
#sendToSlack(findLongProcess(p))
