module DbTable

  def DbTable.load(table_filename)
    return Marshal.load(File.new(table_filename)) if File.exists?(table_filename)
  end

  def DbTable.db_dir()
    return '/var/ps_db'
  end

  def DbTable.save(obj, table_filename)
    out_file = File.new(table_filename, File::WRONLY|File::TRUNC|File::CREAT)
    if out_file.flock(File::LOCK_EX | File::LOCK_NB)
      Marshal.dump(obj, out_file)
    end
    out_file.close()
  end
end
