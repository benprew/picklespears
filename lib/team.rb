
class Team
  require 'db_table'

  TableFilename = 'teams.o'

  attr_accessor :name, :division

  @@teams = DbTable.load(DbTable.db_dir() + '/' + TableFilename)

  def eql?(other)
    @name == other.name
  end

  def hash
    @name.hash
  end

  def Team.teams=(teams)
    @@teams = teams
  end

  def Team.teams
    return @@teams
  end

  def Team.save
    DbTable.save(@@teams, DbTable.db_dir() + '/' + TableFilename)
  end
end
