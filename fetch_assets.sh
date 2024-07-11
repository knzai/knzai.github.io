file_id='1kIqp7dlp3ve_OZwADFs-07_ufVsyChBLz_1YKgn8ElU'
gapi_url='https://www.googleapis.com/drive/v2'
ua='github.com/knzai'
mime='mimeType=application/pdf'
target='static/assets/Kenzi Connor Resume.pdf'

wget -O 'tempfile' --user-agent=$ua "$gapi_url/files/$file_id/export?$mime&key=$GAPI_KEY"

if [ $(du -k tempfile | cut -f1) -gt 30 ]; then
  mv tempfile "$target"
else
  exit 1
fi