
{{- define "portal-admin.pod" -}}
serviceAccountName: {{ template "portal-admin.serviceAccountName" . }}
automountServiceAccountToken: {{ .Values.serviceAccount.autoMount }}
{{- if .Values.securityContext }}
securityContext:
{{ toYaml .Values.securityContext | indent 2 }}
{{- end }}
containers:
  - name: {{ .Chart.Name }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- if .Values.command }}
    command:
    {{- range .Values.command }}
      - {{ . }}
    {{- end }}
  {{- end}}
{{- if .Values.containerSecurityContext }}
    securityContext:
{{- toYaml .Values.containerSecurityContext | nindent 6 }}
{{- end }}
    {{/* ports:
      - name: {{ .Values.podPortName }}
        containerPort: {{ .Values.service.targetPort }}
        protocol: TCP */}}
    {{- if .Values.env }}
    env:
{{- range $key, $value := .Values.env }}
      - name: "{{ tpl $key $ }}"
        value: "{{ tpl (print $value) $ }}"
{{- end }}
    {{- end }}
    {{- if .Values.envFromSecret }}
    envFrom:
      - secretRef:
          name: {{ tpl .Values.envFromSecret . }}
    {{- end }}
    {{/* livenessProbe:
{{ toYaml .Values.livenessProbe | indent 6 }}
    readinessProbe:
{{ toYaml .Values.readinessProbe | indent 6 }}
{{- if .Values.lifecycleHooks }}
    lifecycle: {{ tpl (.Values.lifecycleHooks | toYaml) . | nindent 6 }}
{{- end }} */}}
    resources:
{{ toYaml .Values.resources | indent 6 }}
{{- with .Values.extraContainers }}
{{ tpl . $ | indent 2 }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
{{ toYaml . | indent 2 }}
{{- end }}
{{- $root := . }}
{{- with .Values.affinity }}
affinity:
{{ tpl (toYaml .) $root | indent 2 }}
{{- end }}
{{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}
