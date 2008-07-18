drop table if exists divisions;
drop table if exists teams;
drop table if exists games;
drop table if exists players;
drop table if exists players_teams;

create table divisions (
  id     int           not null auto_increment,
  name   varchar(128)  not null,
  league varchar(128)  not null,
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
  reminder_sent boolean not null default false,
  team_id int not null,
  constraint fk_games_teams foreign key (team_id) references teams(id),
  primary key (id)
) engine=InnoDB;

create table players (
  id int not null auto_increment,
  name varchar(128) not null,
  email_address varchar(256),
  phone_number varchar(16),
  is_sub boolean not null default false,
  primary key (id)
) engine=InnoDB;

create table players_teams (
  player_id int not null,
  team_id int null null,
  constraint fk_players_players_teams foreign key (player_id)
  	     references players(id),
  constraint fk_teams_players_teams foreign key (team_id)
  	     references teams(id)
) engine=InnoDB;
