// Fills ${VAR} placeholders in the template from environment variables.
const fs = require('fs');
const tpl = fs.readFileSync('/credentials/credentials.template.json', 'utf8');
const missing = [];
const out = tpl.replace(/\$\{([A-Z0-9_]+)\}/g, (_, k) => {
  const v = process.env[k];
  if (!v) missing.push(k);
  return (v || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
});
if (missing.length) console.warn('WARNING: empty env vars: ' + [...new Set(missing)].join(', '));
JSON.parse(out); // fail early on bad JSON
fs.writeFileSync('/tmp/credentials.json', out);
