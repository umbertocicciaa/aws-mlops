{{/*
Expand the name of the chart to include the release name
*/}}
{{- define "frontend-helm-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the image name and tag
*/}}
{{- define "frontend-helm-chart.image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag | quote -}}
{{- end -}}

{{/*
Return the service name
*/}}
{{- define "frontend-helm-chart.serviceName" -}}
{{- printf "%s-service" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the secret name
*/}}
{{- define "frontend-helm-chart.secretName" -}}
{{- printf "%s-secrets" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
    Generates standard Kubernetes labels for resources managed by this Helm chart.
    - app.kubernetes.io/name: The name of the Helm chart (from the "frontend-helm-chart.name" helper).
    - app.kubernetes.io/instance: The release name of the Helm deployment.
    Usage: Include this helper to ensure consistent labeling across resources.
*/}}
{{- define "frontend-helm-chart.labels" -}}
app.kubernetes.io/name: {{ include "frontend-helm-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Returns the name of the Helm chart for the frontend, using .Values.nameOverride if set,
otherwise defaults to .Chart.Name. The result is truncated to 63 characters and any trailing
hyphens are removed to ensure Kubernetes resource name compliance.
*/}}
{{- define "frontend-helm-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}