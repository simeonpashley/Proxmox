#!/usr/bin/env sh

if test -z "$VARCHAR"
then
	VARCHAR="255"
fi

# 2022-06-16 : SED configured for migrating HomeAssistant data
sed \
-e '/PRAGMA.*;/ d' \
-e '/BEGIN TRANSACTION.*/ d' \
-e '/COMMIT;/ d' \
-e '/.*sqlite_sequence.*;/d' \
-e "s/ varchar/ varchar($VARCHAR)/g" \
-e 's/"events"/`events`/g' \
-e 's/"recorder_runs"/`recorder_runs`/g' \
-e 's/"schema_changes"/`schema_changes`/g' \
-e 's/"states"/`states`/g' \
-e 's/"end"/`end`/g' \
-e 's/CREATE TABLE \(`\w\+`\)/DROP TABLE IF EXISTS \1;\nCREATE TABLE \1/' \
-e 's/\(CREATE TABLE.*\)\(PRIMARY KEY\) \(AUTOINCREMENT\)\(.*\)\();\)/\1AUTO_INCREMENT\4, PRIMARY KEY(id)\5/' \
-e "s/'t'/1/g" \
-e "s/'f'/0/g" \
$1
