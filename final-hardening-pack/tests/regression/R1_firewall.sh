#!/bin/bash
# R1: Verify firewall still enforces policy
echo "=== R1 Firewall Regression ==="

TARGET_IP="10.10.20.10"
TARGET_HTTPS="${TARGET_IP}:8443"   # mets 443 si besoin

echo "Target: $TARGET_HTTPS"

# Positive: HTTPS to srv-web should work
echo -n "P1: HTTPS -> srv-web... "
STATUS=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 https://$TARGET_HTTPS/)
if [ "$STATUS" = "200" ]; then
    echo "PASS, HTTP code $STATUS"
else
    echo "FAIL, got HTTP code $STATUS"
    exit 1
fi

# Negative: Random port should timeout
echo -n "N1: Port 12345 → srv-web... "
nc -vz -w 3 10.10.20.10 12345 > /dev/null 2>&1 \
  && { echo "FAIL (should be blocked)"; exit 1; } || echo "PASS (blocked)"

# Negative: MySQL should timeout
echo -n "N2: Port 3306 → srv-web... "
nc -vz -w 3 10.10.20.10 3306 > /dev/null 2>&1 \
  && { echo "FAIL (should be blocked)"; exit 1; } || echo "PASS (blocked)"

echo "R1: All checks passed"


