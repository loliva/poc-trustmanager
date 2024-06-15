#!/bin/bash

# Path to the certificate file
CERT_FILE="/path/to/certificate.crt"

# Path to the CA bundle file (if applicable)
CA_BUNDLE="/path/to/ca-bundle.crt"

# Check if the certificate file exists
if [ ! -f "$CERT_FILE" ]; then
    echo "Certificate file not found: $CERT_FILE"
    exit 1
fi

# Validate the certificate
openssl x509 -in "$CERT_FILE" -text -noout

# Check the certificate expiration date
EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
CURRENT_DATE=$(date +%Y%m%d)

if [ "$CURRENT_DATE" -gt "$EXPIRY_DATE" ]; then
    echo "Certificate has expired on $EXPIRY_DATE"
    exit 1
fi

# Verify the certificate against the CA bundle (if applicable)
if [ -n "$CA_BUNDLE" ]; then
    openssl verify -CAfile "$CA_BUNDLE" "$CERT_FILE"
    if [ $? -ne 0 ]; then
        echo "Certificate verification failed"
        exit 1
    fi
fi

echo "Certificate is valid"
