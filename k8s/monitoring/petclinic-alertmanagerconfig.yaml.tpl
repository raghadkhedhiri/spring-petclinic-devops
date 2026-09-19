apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: petclinic-email
  namespace: petclinic
  labels:
    alertmanager: petclinic-email
spec:
  route:
    receiver: petclinic-gmail
    groupBy:
      - alertname
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
  receivers:
    - name: petclinic-gmail
      emailConfigs:
        - to: REPLACE_WITH_GMAIL_ADDRESS
          from: REPLACE_WITH_GMAIL_ADDRESS
          smarthost: smtp.gmail.com:587
          authUsername: REPLACE_WITH_GMAIL_ADDRESS
          authPassword:
            name: petclinic-gmail-smtp
            key: password
          requireTLS: true
          sendResolved: true
