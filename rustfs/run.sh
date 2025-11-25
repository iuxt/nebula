docker rm -f rustfs

mkdir data logs
sudo chown -R 10001:10001 data logs

docker run -d \
  --name rustfs \
  -p 9000:9000 \
  -p 9001:9001 \
  --user 10001:10001 \
  -v ./data:/data \
  -v ./logs:/logs \
  --env-file .env \
  rustfs/rustfs:latest \
  /data
