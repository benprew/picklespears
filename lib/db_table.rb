class DbTable

  def initialize()
    @@db_dir ||= '/var/ps_db'
    @@table_values = Marshal.load(File.new(@@db_dir + '/' + @@table_filename))
  end

  def select()
    return @@table_values.select { |x| yield(x) }
  end

  def save()
    teams_file = File.new(table_filename(), "w")
    if teams_file.flock(File::LOCK_EX | File::LOCK_NB)
      Marshal.dump(teams, teams_file)
    end
  end
end
