{{/*
Expand the name of the chart.
*/}}
{{- define "store.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "store.fullname" -}}
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
{{- define "store.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "store.labels" -}}
helm.sh/chart: {{ include "store.chart" . }}
{{ include "store.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "store.dashboard.labels" -}}
helm.sh/chart: {{ include "store.chart" . }}
{{ include "store.dashboard.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "store.storefront.labels" -}}
helm.sh/chart: {{ include "store.chart" . }}
{{ include "store.storefront.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "store.selectorLabels" -}}
app.kubernetes.io/name: {{ include "store.name" . }}-api
app.kubernetes.io/instance: {{ .Release.Name }}-api
{{- end }}

{{- define "store.dashboard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "store.name" . }}-dashboard
app.kubernetes.io/instance: {{ .Release.Name }}-dashboard
{{- end }}

{{- define "store.storefront.selectorLabels" -}}
app.kubernetes.io/name: {{ include "store.name" . }}-storefront
app.kubernetes.io/instance: {{ .Release.Name }}-storefront
{{- end }}
{{/*
Create the name of the service account to use
*/}}
{{- define "store.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "store.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "ecr.imagePullSecret" }}
{{- with .Values.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}
