{{/* vim: set filetype=mustache: */}}

{{- define "template" -}}
{{- $name := index . 0 -}}
{{- $context := index . 1 -}}
{{- $v:= $context.Template.Name | split "/" -}}
{{- $n := len $v -}}
{{- $last := sub $n 1 | printf "_%d" | index $v -}}
{{- $wtf := $context.Template.Name | replace $last $name -}}
{{ include $wtf $context }}
{{- end -}}


{{- define "service-auth.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}


{{/* Name of the application. Example: service-auth */}}
{{- define "service-auth.name" -}}
  {{- printf "%s" .Chart.Name | splitList "-" | last -}}
{{- end -}}


{{/* Full name of the application: <name>-<env> Example: service-auth */}}
{{- define "service-auth.fullname" -}}
  {{- printf "%s-%s" (include "service-auth.name" .) (include "service-auth.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Docker image of the service-auth deployment. */}}
{{- define "service-auth.container" -}}
{{- $repo := required "A valid service-auth docker repo value is required" .Values.image.repo -}}
{{- $path := required "A valid service-auth docker path value is required" .Values.image.path -}}
{{- $tag := required "A valid service-auth docker tag value is required" .Values.image.tag -}}
{{- printf "%s%s:%s" $repo $path $tag -}}
{{- end -}}


{{/* Chart name and version as used by the chart label. Example: service-auth-1.0.1 */}}
{{- define "service-auth.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Domain name based on envtype. zipzero.net for development, zipzero.com for production Example: zipzero.net */}}
{{- define "service-auth.domain" -}}
  {{- if .Values.domain -}}
    {{- .Values.domain -}}
  {{- else -}}
    {{- if or (eq .Values.envtype "int") (eq .Values.envtype "dev") (eq .Values.envtype "cid") (eq .Values.envtype "tst") -}}
      {{- print "zipzero.net" -}}
    {{- else if or (eq .Values.envtype "stg") (eq .Values.envtype "uat") (eq .Values.envtype "prd") -}}
      {{- print "zipzero.com" -}}
    {{- else}}
      {{- fail (printf "ERROR: 'invalid envtype'") -}}
    {{- end -}}
  {{- end -}}
{{- end -}}



{{- define "service-auth.dns" -}}
  {{- $host := default (include "service-auth.fullname" .) .Values.dns.host -}}
    {{- printf "%s.%s" $host (include "service-auth.domain" .) -}}
{{- end -}}

{{- define "service-auth.labels" -}}
env: {{ template "service-auth.env" . }}
envtype: {{ .Values.envtype }}
release: {{ .Release.Name | quote }}
app: service-auth 
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "service-auth.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}


{{- define "service-auth.selector" -}}
app: service-auth 
env: {{ template "service-auth.env" . }}
{{- end -}}


{{- define "mongo.db" -}}
  {{- if .postfix }}
    {{- printf " %s-%s-service-auth-%s-%s" .Release.Namespace (include "service-auth.name" .) (include "service-auth.env" .) .postfix -}}
  {{- else }}
    {{- printf " %s-%s-service-auth-%s" .Release.Namespace (include "service-auth.name" .) (include "service-auth.env" .) -}}
  {{- end }}
{{- end -}}


{{- /* Create full database user name for MongoDB. Example: service-auth-dev01 */ -}}
{{- define "mongo.user" -}}
  {{- printf "%s-%s-%s" .Release.Namespace (include "service-auth.name" .) (include "service-auth.env" .) -}}
{{- end -}}
