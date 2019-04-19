require 'mysql2'

begin
  def inizialize_db(host, username, password, database)
    @client = Mysql2::Client.new(host: host, username: username, password: password, database: database)
  end

  def select_data(table)
    @client.query("SELECT * FROM #{table} LIMIT 40")
  end

  def insert_data(table, column1, data1, column2, data2, id)
    @client.query("UPDATE #{table} SET #{column1} = \"#{data1}\", #{column2} = \"#{data2}\" WHERE id = \"#{id}\";")
  end

  def clean_name(r)
    sname = r.to_s.split.uniq.join(" ").gsub(/Twp/, 'Township').gsub(/Hwy/, 'Highway')
    if sname.include? "/"
      sname = sname[/([^\/]+)$/].lstrip+' '+sname[/^(.*[\\\/])/].downcase.tr("/", "")
      if sname.include? ","
        sname.match(",") {|m| sname = m.pre_match+' ('+m.post_match.to_s.lstrip+')'}
      else
        sname.downcase!
      end
    end
    return sname
  end

  TABLE = "hle_dev_test_halyna_merkotan"
  COLUMN1 = "clean_name"
  COLUMN2 = "sentence"
  HOST = ''
  USERNAME = ''
  PASSWORD = ''
  DATABASE = ''

  inizialize_db(host = HOST, username = USERNAME, password = PASSWORD, database = DATABASE)

  result = select_data(table = TABLE)
  result.each do |row| 
    sname = clean_name(r = row["candidate_office_name"])
    sentence = "The candidate is running for the #{sname} office"
    insert_data(table = TABLE, column1 = COLUMN1, data1 = sname, column2 = COLUMN2, data2 = sentence, id = row["id"])
  end

rescue Mysql2::Error => e
  puts e.errno
  puts e.error
ensure
  @client.close if @client
end
