drop table if exists divisions;
drop table if exists teams;
drop table if exists games;

create table divisions (
  id    int           not null auto_increment,
  name  varchar(128)  not null,
  primary key (id)
) engine=InnoDB;

create table teams (
  id int not null auto_increment,
  name varchar(128) not null,
  division_id int not null,
  constraint fk_teams_divisions foreign key (division_id) references divisions(id),
  primary key (id)
) engine=InnoDB;

create table games (
  id int not null auto_increment,
  date date not null,
  description varchar(256) not null,
  team_id int not null,
  constraint fk_games_teams foreign key (team_id) references teams(id),
  primary key (id)
) engine=InnoDB;
