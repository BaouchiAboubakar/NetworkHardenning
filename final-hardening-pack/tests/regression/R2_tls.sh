#!/bin/bash
# R2: Verify TLS configuration still matches profile
echo "=== R2 TLS Regression ==="

TLS_HOST="10.10.20.10:8443"

# Check TLS 1.2 works
echo -n "P1: TLS 1.2 accepted... "
openssl s_client -connect $TLS_HOST -tls1_2 </dev/null 2>&1 | grep -q "Protocol  : TLSv1.2" \
  && echo "PASS" || { echo "FAIL"; exit 1; }


# Check HSTS header present
echo -n "P2: HSTS header... "
curl -sk -D- https://$TLS_HOST/ 2>/dev/null | grep -qi "strict-transport-security" \
  && echo "PASS" || { echo "FAIL (no HSTS)"; exit 1; }

echo "R2: All checks passed"


