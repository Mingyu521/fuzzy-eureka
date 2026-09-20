@echo off
set PATH=C:\Ruby34-x64\bin;%PATH%
set SSL_CERT_FILE=C:\Ruby34-x64\ssl\cert.pem
ruby bin\rails server -p 3000
