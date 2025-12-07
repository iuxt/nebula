docker rm -f rustfs

mkdir data logs
sudo chown -R 10001:10001 data logs

docker run -d \
  --name rustfs \
  --network iuxt \
  -v ./data:/data \
  -v ./logs:/logs \
  --env-file .env \
  rustfs/rustfs:latest \
  /data

../public/add_config_to_nginx.py

