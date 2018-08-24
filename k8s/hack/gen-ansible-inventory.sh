#!/bin/bash

echo "[all]"

kubectl get nodes -ogo-template='{{- range .items}}
      {{- .metadata.name }}{{ "\t" }}
      {{- range .status.addresses }}
          {{- .type }}={{ .address }}{{ "\t" }}
      {{- end }}GPU={{ index .metadata.labels "node-role.qiniu.com/gpu" }}{{"\n"}}
{{- end}}' | grep InternalIP | while read l; do
        ip=$(echo "$l" | perl -lne 'print $1 if /InternalIP=([^\s]*)/')
        hostname=$(echo "$l" | perl -lne 'print $1 if /Hostname=([^\s]*)/')
        has_gpu=$(echo "$l" | perl -lne 'print "has_gpu=$1" if /GPU=(true)/')
        printf '%s ansible_ssh_host=%s %s\n' "$hostname" "$ip" "$has_gpu"
done
