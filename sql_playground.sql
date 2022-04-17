CREATE TABLE recent (path TEXT PRIMARY KEY, last_opened INTEGER, pinned INTEGER) WITHOUT ROWID;
insert into recent (path, last_opened, pinned) values ("qwert", 2000, false);
insert into recent (path, last_opened, pinned) values ("second", 2010, false);
insert into recent (path, last_opened, pinned) values ("third", 2020, false);
insert into recent (path, last_opened, pinned) values ("pinned-old", 2005, true);
insert into recent (path, last_opened, pinned) values ("pinned-new", 2025, true);

-- clean ver 1
select min(last_opened) from (select last_opened from recent where pinned == 0 order by last_opened desc limit 
max(4 - (select count(*) from recent where pinned == 1), 0))

-- clean ver 2
select * from recent where pinned == 0 and last_opened < (select min(last_opened) from (select last_opened from recent where pinned == 0 order by last_opened desc limit 
max(4 - (select count(*) from recent where pinned == 1), 0)))

-- clean ver 3
select * from recent where pinned == 0 and last_opened < (
  select min(last_opened) from (
    with lista(last_opened) as (
      select last_opened from recent order by last_opened desc limit 1
    ) select * from (
      select last_opened from recent where pinned == 0
      order by last_opened desc limit max(
        4 - (select count(*) from recent where pinned == 1), 0
      )
    ) union select * from lista
  )
)

-- sel
with pinned_items (path, last_opened, pinned)
as (select * from recent where pinned == 1)
select * from (
  select * from recent where pinned == 0
  order by last_opened desc limit max(
    4 - (select count(*) from pinned_items), 0
  )
) union select * from pinned_items
order by pinned desc, last_opened desc

-- update or insert keep pinned state
insert or replace into recent (path, last_opened, pinned) values ("pinned-old", 2006, (select pinned from recent where path == "pinned-old"))

select * from recent




drop table if exists tag;
CREATE TABLE tag (name TEXT PRIMARY KEY, shortcut TEXT NULLABLE, after TEXT NULLABLE) WITHOUT ROWID;
insert into tag (name, after) values ("1", null);
insert into tag (name, after) values ("2", "1");
insert into tag (name, after) values ("3", "2");
insert into tag (name, after) values ("4", "3");
insert into tag (name, after) values ("5", "4");
select * from tag;

-- 12345 -> 13245 (3, 1)
update tag set after = (select after from tag where name == "3") where after == "3";
update tag set after = "1" where name == "3";
update tag set after = "3" where after == "1" and name != "3";
select * from tag;

-- 123 -> 312 (3, null)
update tag set after = (select after from tag where name == "3") where after == "3";
update tag set after = null where name == "3";
update tag set after = "3" where after == null and name != "3";
select * from tag;