{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-broker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafka-broker.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kafka-broker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka-broker.labels" -}}
helm.sh/chart: {{ include "kafka-broker.chart" . }}
{{ include "kafka-broker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka-broker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka-broker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kafka-broker.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kafka-broker.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Find the name of the OpenShift domain
*/}}
{{- define "kafka-broker.ocpDomain" -}}
{{- $ingresscontroller := (lookup "operator.openshift.io/v1" "IngressController" "openshift-ingress-operator" "default") | default dict }}
{{- $status := (get $ingresscontroller "status") | default dict }}
{{- $ocpDomain := (get $status "domain") | default dict }}
{{- printf "%s" $ocpDomain }}
{{- end }}

{{/*
ArgoCD Syncwave
*/}}
{{- define "kafka-broker.argocd-syncwave" -}}
{{- if .Values.argocd }}
{{- if and (.Values.argocd.syncwave) (.Values.argocd.enabled) -}}
argocd.argoproj.io/sync-wave: "{{ .Values.argocd.syncwave }}"
{{- else }}
{{- "{}" }}
{{- end }}
{{- else }}
{{- "{}" }}
{{- end }}
{{- end }}

{{/* 
Kafka Bootstrap Server
*/}}
{{- define "kafka-broker.bootstrapServer" -}}
{{- if .Values.bootstrapServer }}
{{- .Values.bootstrapServer }}
{{- else if .Values.namespace }}
{{- printf "%s-kafka-bootstrap.%s.svc.cluster.local:9092" (include "kafka-broker.name" .) .Values.namespace }}
{{- else }}
{{- printf "%s-kafka-bootstrap.%s.svc.cluster.local:9092" (include "kafka-broker.name" .) .Release.Namespace }}
{{- end }}
{{- end }}

{{/* 
Kafka authentication
*/}}
{{- define "kafka-broker.authentication" -}}
{{- if eq .Values.authentication.saslMechanism "SCRAM-SHA-512" }}
authentication:
  type: scram-sha-512
{{- else }}
authentication: {}
{{- end }}
{{- end }}
