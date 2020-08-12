# script to backup flarum and upload to S3

# backup mysql
backup_mysql() {
  /opt/bitnami/mysql/bin/mysqldump --lock-tables -u flarum -p$(grep -o "'.*'" bitnami_credentials | sed "s/'//g") flarumdb > $1/mysql.bak
}

# backup flarum
backup_flarum() {
  # add all flarum folders that need to be backed up here
  cp -R ~/flarum/public/assets $1/flarum/public/assets
}

# backup and upload
backup_and_upload() {
  backuptime=$(date +"%Y%m%d_%s")
  backupdir=~/backups/$(backuptime)
  backupfile=$(backupdir)/flarum-bkp_$(backuptime).zip
  mkdir $(backupdir)
  backup_mysql $(backupdir) &
  backup_flarum $(backupdir)
  wait
  zip -r $(backupfile) $(backupdir)/*
  aws s3 upload $(backupfile) s3://indiacovidforum/backups/
}

backup_and_upload
