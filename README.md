# Cycloid wordpress demo

Do not use this in production. This is a standalone Wordpress container already configured
for Cycloid demo.

# Modify

## Sqlite dump

```
sqlite3 /var/wordpress/database/.ht.sqlite
.output /tmp/dump
.dump
.exit
```

## Sqlite restore

```
sqlite3 /var/wordpress/database/.ht.sqlite < /tmp/dump
```

## Build and push

```
docker build -t cycloid/demo-wordpress:latest .
docker push cycloid/demo-wordpress:latest
```

## Wordpress

Default login : cycloid
Default password : Cycloid2019
