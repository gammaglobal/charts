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


{{- define "service-recovery.env" -}}
  {{- $envtype := required "A valid envtype value is required" .Values.envtype -}}
  {{- $envid := required "A valid envid value is required" .Values.envid -}}
  {{- printf "%s%s" $envtype $envid -}}
{{- end -}}


{{/* Name of the application. Example: service-recovery */}}
{{- define "service-recovery.name" -}}
  {{- printf "%s" .Chart.Name -}}
{{- end -}}


{{/* Full name of the application: <name>-<env> Example: service-recovery */}}
{{- define "service-recovery.fullname" -}}
  {{- printf "%s-%s" (include "service-recovery.name" .) (include "service-recovery.env" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/* Docker image of the service-recovery deployment. */}}
{{- define "service-recovery.container" -}}
{{- $repo := required "A valid service-recovery docker repo value is required" .Values.image.repo -}}
{{- $path := required "A valid service-recovery docker path value is required" .Values.image.path -}}
{{- $tag := required "A valid service-recovery docker tag value is required" .Values.image.tag -}}
{{- printf "%s%s:%s" $repo $path $tag -}}
{{- end -}}


{{/* Chart name and version as used by the chart label. Example: service-recovery-1.0.1 */}}
{{- define "service-recovery.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Domain name based on envtype. zipzero.net for development, zipzero.com for production Example: zipzero.net */}}
{{- define "service-recovery.domain" -}}
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



{{- define "service-recovery.dns" -}}
  {{- $host := default (include "service-recovery.fullname" .) .Values.dns.host -}}
    {{- printf "%s.%s" $host (include "service-recovery.domain" .) -}}
{{- end -}}

{{- define "service-recovery.labels" -}}
env: {{ template "service-recovery.env" . }}
envtype: {{ .Values.envtype }}
release: {{ .Release.Name | quote }}
app: service-recovery 
{{- end -}}

{{- define "chart.labels" -}}
chart: {{ template "service-recovery.chart" . }}
heritage: {{ .Release.Service | quote }}
{{- end -}}


{{- define "service-recovery.selector" -}}
app: service-recovery 
env: {{ template "service-recovery.env" . }}
{{- end -}}


{{- define "mongo.db" -}}
  {{- if .postfix }}
    {{- printf " %s-%s-service-recovery-%s-%s" .Release.Namespace (include "service-recovery.name" .) (include "service-recovery.env" .) .postfix -}}
  {{- else }}
    {{- printf " %s-%s-service-recovery-%s" .Release.Namespace (include "service-recovery.name" .) (include "service-recovery.env" .) -}}
  {{- end }}
{{- end -}}


{{- /* Create full database user name for MongoDB. Example: service-recovery-dev01 */ -}}
{{- define "mongo.user" -}}
  {{- printf "%s-%s-%s" .Release.Namespace (include "service-recovery.name" .) (include "service-recovery.env" .) -}}
{{- end -}}
