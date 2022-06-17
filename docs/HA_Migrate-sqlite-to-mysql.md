copied gist locally from here...
ref: https://gist.github.com/PattaFeuFeu/c4475457854f42f64f21268777d64d87

copied the referenced `sqlite3-to-mysql.sh` locally, updated and saved as `ha-to-mysql.sh`

# Original
---
# Migrate Home Assistant’s sqlite database to MySQL, specifically MariaDB (10)

After having added a decent amount of entities to my Home Assistant setup, the user interface—especially the history tab, but also the history for each entity—became very sluggish.
Having to wait for up to 30 seconds to see the history graph for a single entity became the norm with an sqlite file weighing in at 6GB and millions of entries in the “events” and “states” tables.

I wanted to keep my acquired data, so I had to migrate it from the current sqlite file to a MySQL database instead of starting anew.
I’ve done this using Home Assistant version 0.81 and MariaDB 10. Some parts might change in the future.

## Dump Home Assistant sqlite database

Make sure you have `sqlite3` installed and in your path—e.g. via installing it using `apt-get install sqlite3`.

Then, stop home assistant to have a non-changing database file.

Change to your homeassitant data folder and then, using

```bash
sqlite3 home-assistant_v2.db .dump | gzip -c > ha-database_sqlite.dump.sql.gz
```

you can dump your current sqlite Home Assistant database into an sql file.
Depending on your database size and I/O speed of your device, this might take many minutes, even hours.

## Convert sqlite dump to something suitable for MySQL

Out of the box, the sqlite dump doesn’t work in a MySQL setup.

See the whole content in `ha-to-mysql.sh`.

You might need to make the shell file executable using `chmod +x ha-to-mysql.sh`

Afterwards, you start the conversion process using

```bash
sudo ./ha-to-mysql.sh ha-database_sqlite.dump.sql.gz > mysql_import_me.sql
```

Like the initial dump, this may take quite a while to finish. And you won’t have a progress bar either.

## Import the converted sql file into a MySQL database

The file won’t have a database creation query in it, so you start by adding one to your MySQL database yourself.

Connect to your local mysql instance, enter the root password when prompted:

```bash
mysql -u root -p
```

Create a database called “homeassistant”:

```sql
CREATE DATABASE homeassistant;
```

Create a user “homeassistant” with access to the database so that you don’t have to use your root account:

```sql
GRANT ALL PRIVILEGES ON homeassistant.* to 'homeassistant' IDENTIFIED BY '<yourpassword>'
```

Now you are ready to import. 
To speed up the process, I first set `autocommit` to false and afterwards manually commited. I found that this increased the speed of the import. YMMV.

```sql
SET autocommit=0;
source <full path to your mysql_import_me.sql file>;
commit;
```

Again, this will probably take some time.

### Fix some issues the import file doesn’t address yet

Find out current max of `event_id` to set `AUTO_INCREMENT`:

```sql
MariaDB [homeassistant]> SELECT MAX(event_id) AS Count FROM events;
+---------+
| Count   |
+---------+
| 3189954 |
+---------+
1 row in set (0.000 sec)
```

Then alter the `events` table, use the previous max, incremented by 1 (=> +1), and set it as the starting point for `AUTO_INCREMENT`:

```sql
ALTER TABLE events MODIFY COLUMN event_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3189955;
```

_OPTIONAL: I had to drop the foreign key before I could alter the auto increment. It will be reinstated below. _
```sql
ALTER TABLE states DROP FOREIGN KEY states_ibfk_1;
```

Repeat this process for the three other tables. Especially `events` and `states` will take some time (half an hour was the longest I saw so far).

```sql
MariaDB [homeassistant]> SELECT MAX(state_id) AS Count FROM states;
+---------+
| Count   |
+---------+
| 3189396 |
+---------+
1 row in set (0.000 sec)

MariaDB [homeassistant]> ALTER TABLE states MODIFY COLUMN state_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3189397;
```

```
MariaDB [homeassistant]> SELECT MAX(run_id) as Count FROM recorder_runs;
+-------+
| Count |
+-------+
|   192 |
+-------+
1 row in set (0.042 sec)

MariaDB [homeassistant]> ALTER TABLE recorder_runs MODIFY COLUMN run_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=193;
```

```sql
MariaDB [homeassistant]> SELECT MAX(change_id) AS Count FROM schema_changes;
+-------+
| Count |
+-------+
|     3 |
+-------+
1 row in set (0.043 sec)

MariaDB [homeassistant]> ALTER TABLE schema_changes MODIFY COLUMN change_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
```

Then, drop the foreign key of `states`, should it exist, so we can recreate it on our own with the right parameters.

```sql
ALTER TABLE states DROP FOREIGN KEY states_ibfk_1;
ALTER TABLE states ADD CONSTRAINT `states_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`)
```

## Change `configuration.yaml` to use the MySQL database

You’re almost done! Only task left is to add MySQL to your HA configuration.

See https://www.home-assistant.io/components/recorder/#custom-database-engines for your specific setup.

For MariaDB 10, I had to set

```yaml
recorder:
  db_url:  mysql://homeassistant:<YOURCHOSENPASSWORD>@<MARIADB10HOST>:3607/homeassistant
```

And that’s it!

---

My suite of changes 2022-06-17

### event_data

```sql
SELECT MAX(data_id) AS Count FROM event_data;
ALTER TABLE event_data MODIFY COLUMN data_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=

### events

```sql
SELECT MAX(event_id) AS Count FROM events;
ALTER TABLE events MODIFY COLUMN event_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

### recorder_runs
```sql
SELECT MAX(run_id) as Count FROM recorder_runs;
ALTER TABLE recorder_runs MODIFY COLUMN run_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

### schema_changes

```sql
SELECT MAX(change_id) AS Count FROM schema_changes;
ALTER TABLE schema_changes MODIFY COLUMN change_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

### states

```sql
SELECT MAX(state_id) AS Count FROM states;
ALTER TABLE states MODIFY COLUMN state_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

### state_attributes

```sql
SELECT MAX(attributes_id) AS Count from state_attributes;
ALTER TABLE state_attributes MODIFY COLUMN attributes_id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

### statistics

```sql
SELECT MAX(id) AS Count from statistics;
ALTER TABLE statistics MODIFY COLUMN id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

### statistics_meta

```sql
SELECT MAX(id) AS Count from statistics_meta;
ALTER TABLE statistics_meta MODIFY COLUMN id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

### statistics_runs
*NO CHANGE*

### statistics_short_term

```sql
SELECT MAX(id) AS Count from statistics_short_term;
ALTER TABLE statistics_short_term MODIFY COLUMN id INT NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=
```

