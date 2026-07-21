+++
date = '{{ .Date }}'
{{/*
  Notes aren't published as standalone pages — they all live on the single
  /notes/ page. `list = 'local'` keeps them available to that page's template
  while `render = 'never'` skips the individual HTML output.
*/}}
[build]
  list = 'local'
  render = 'never'
+++
