## 对于windows用户

### 创建frpc为服务

```bat
sc create frpc binpath="C:\Users\iuxt\1\frpc\frpc.exe -c C:\Users\iuxt\1\frpc\frpc.ini" DisplayName=frpc
```


## 双向验证

```toml
# frpc.toml
transport.tls.certFile = "/to/cert/path/client.crt"
transport.tls.keyFile = "/to/key/path/client.key"
transport.tls.trustedCaFile = "/to/ca/path/ca.crt"

# frps.toml
transport.tls.certFile = "/to/cert/path/server.crt"
transport.tls.keyFile = "/to/key/path/server.key"
transport.tls.trustedCaFile = "/to/ca/path/ca.crt"
```

<https://gofrp.org/zh-cn/docs/features/common/network/network-tls/>

### OpenSSL 生成证书示例
x509: certificate relies on legacy Common Name field, use SANs or temporarily enable Common Name matching with GODEBUG=x509ignoreCN=0

如果出现上述报错，是因为 go 1.15 版本开始废弃 CommonName，因此推荐使用 SAN 证书。

下面简单示例如何用 openssl 生成 ca 和双方 SAN 证书。

准备默认 OpenSSL 配置文件于当前目录。此配置文件在 linux 系统下通常位于 /etc/pki/tls/openssl.cnf，在 mac 系统下通常位于 /System/Library/OpenSSL/openssl.cnf。

如果存在，则直接拷贝到当前目录，例如 cp /etc/pki/tls/openssl.cnf ./my-openssl.cnf。如果不存在可以使用下面的命令来创建。

```bash
cat > my-openssl.cnf << EOF
[ ca ]
default_ca = CA_default
[ CA_default ]
x509_extensions = usr_cert
[ req ]
default_bits        = 2048
default_md          = sha256
default_keyfile     = privkey.pem
distinguished_name  = req_distinguished_name
attributes          = req_attributes
x509_extensions     = v3_ca
string_mask         = utf8only
[ req_distinguished_name ]
[ req_attributes ]
[ usr_cert ]
basicConstraints       = CA:FALSE
nsComment              = "OpenSSL Generated Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = CA:true
EOF
```

生成默认 ca:

```bash
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=example.ca.com" -days 5000 -out ca.crt
```

生成 frps 证书:

```bash
openssl genrsa -out server.key 2048

openssl req -new -sha256 -key server.key \
    -subj "/C=XX/ST=DEFAULT/L=DEFAULT/O=DEFAULT/CN=server.com" \
    -reqexts SAN \
    -config <(cat my-openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,IP:127.0.0.1,DNS:example.server.com")) \
    -out server.csr

openssl x509 -req -days 365 -sha256 \
	-in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
	-extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:example.server.com") \
	-out server.crt
```

生成 frpc 的证书:

```bash
openssl genrsa -out client.key 2048
openssl req -new -sha256 -key client.key \
    -subj "/C=XX/ST=DEFAULT/L=DEFAULT/O=DEFAULT/CN=client.com" \
    -reqexts SAN \
    -config <(cat my-openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:client.com,DNS:example.client.com")) \
    -out client.csr

openssl x509 -req -days 365 -sha256 \
    -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
	-extfile <(printf "subjectAltName=DNS:client.com,DNS:example.client.com") \
	-out client.crt
```

在本例中，server.crt 和 client.crt 都是由默认 ca 签发的，因此他们对默认 ca 是合法的。
