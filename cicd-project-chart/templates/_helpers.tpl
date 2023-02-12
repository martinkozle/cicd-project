{{/*
Expand the name of the chart.
*/}}
{{- define "cicd-project-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cicd-project-chart.fullname" -}}
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
{{- define "cicd-project-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cicd-project-chart.labels" -}}
helm.sh/chart: {{ include "cicd-project-chart.chart" . }}
{{ include "cicd-project-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cicd-project-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cicd-project-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cicd-project-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cicd-project-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create DATABASE_URL environment variable
*/}}
{{- define "cicd-project-chart.databaseUrl" -}}
{{- $databaseUrl := printf "postgresql://%s:%s@db:5432/%s" .Values.env.POSTGRES_USER .Values.env.POSTGRES_PASSWORD .Values.env.POSTGRES_DB }}
{{- $databaseUrl | quote }}
{{- end }}
