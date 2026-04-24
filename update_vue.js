const fs = require('fs');
let content = fs.readFileSync('rexuvia-site/src/components/ModelShowResults.vue', 'utf8');

// 1. Remove polling logic
content = content.replace(/const POLL_INTERVAL_MS = 30_000\nconst MAX_BACKOFF_MS   = 300_000 \/\/ 5 min cap\n/g, '');
content = content.replace(/const refreshing       = ref\(false\)       \/\/ background poll\n/g, '');
content = content.replace(/const lastUpdated      = ref\(null\)        \/\/ Date of last successful fetch\nconst secondsAgo       = ref\(0\)          \/\/ live counter\n/g, '');
content = content.replace(/let pollTimer          = null\nlet clockTimer         = null\nlet backoffDelay       = POLL_INTERVAL_MS\n/g, '');

content = content.replace(/function scheduleNextPoll\(\) \{[\s\S]*?\}\n\n/g, '');
content = content.replace(/async function manualRefresh\(\) \{[\s\S]*?\}\n\n/g, '');
content = content.replace(/\/\/ ── Clock ──────────────────────────────────────────────────────────────\nfunction tickClock\(\) \{[\s\S]*?\}\n\n/g, '');

content = content.replace(/onMounted\(\(\) => \{\n  fetchIndex\(false\)\n  clockTimer = setInterval\(tickClock, 1000\)\n\}\)\n\nonUnmounted\(\(\) => \{\n  clearTimeout\(pollTimer\)\n  clearInterval\(clockTimer\)\n\}\)/g, `onMounted(() => {\n  fetchIndex()\n})`);

content = content.replace(/async function fetchIndex\(isBackground \= false\) \{[\s\S]*?error\.value \= null/g, `async function fetchIndex() {\n  loading.value = true\n  error.value = null`);
content = content.replace(/    if \(isBackground\) refreshing\.value \= true\n    else loading\.value \= true/g, `    loading.value = true`);
content = content.replace(/    results\.value \= incoming\n    lastUpdated\.value = new Date\(\)\n    secondsAgo\.value = 0\n    backoffDelay = POLL_INTERVAL_MS \/\/ reset backoff on success\n/g, `    results.value = incoming\n`);
content = content.replace(/    backoffDelay = Math.min\(backoffDelay \* 2, MAX_BACKOFF_MS\)\n    scheduleNextPoll\(\)\n    return\n/g, `    return\n`);
content = content.replace(/  \} finally \{\n    loading\.value = false\n    refreshing\.value = false\n  \}\n\n  scheduleNextPoll\(\)\n/g, `  } finally {\n    loading.value = false\n  }\n`);

// 2. Update date formatting
content = content.replace(/function fmtDate\(isoStr\) \{\n  return new Intl\.DateTimeFormat\('en-US', \{\n    month: 'short', day: 'numeric', year: 'numeric',\n    hour: '2-digit', minute: '2-digit', hour12: false,\n    timeZoneName: 'short',\n  \}\)\.format\(new Date\(isoStr\)\)\n\}/g, `function fmtDate(isoStr) {\n  return new Intl.DateTimeFormat('en-US', {\n    month: 'short', day: 'numeric', year: 'numeric'\n  }).format(new Date(isoStr))\n}`);

// Remove controls (refresh button, poll status)
content = content.replace(/<button\n        class="ms-refresh-btn"\n        :class="\{ 'ms-spinning': refreshing \}"\n        @click="manualRefresh"\n        :disabled="refreshing"\n        aria-label="Refresh results"\n      >\n        ↻ Refresh\n      <\/button>\n\n      <span class="ms-poll-status">\n        <template v-if="lastUpdated">\n          Updated \{\{ secondsAgo \}\}s ago\n        <\/template>\n        <template v-else>Loading…<\/template>\n      <\/span>/g, '');

content = content.replace(/<!-- Controls bar -->\n    <div v-if="!loading" class="ms-controls">\n      <div class="ms-search-wrap">\n        <input\n          v-model="filterText"\n          class="ms-search"\n          type="search"\n          placeholder="Filter by prompt, model…"\n          aria-label="Filter results"\n        \/>\n        <button v-if="hasFilter" class="ms-clear-btn" @click="clearFilter" aria-label="Clear filter">✕<\/button>\n      <\/div>\n    <\/div>/g, `<!-- Controls bar -->
    <div v-if="!loading" class="ms-controls">
      <div class="ms-search-wrap">
        <input
          v-model="filterText"
          class="ms-search"
          type="search"
          placeholder="Filter by prompt, model…"
          aria-label="Filter results"
        />
        <button v-if="hasFilter" class="ms-clear-btn" @click="clearFilter" aria-label="Clear filter">✕</button>
      </div>
    </div>`);

// Table headers
content = content.replace(/<th class="ms-th ms-th-sortable ms-th-num" @click="toggleSort\('models_queried_count'\)" scope="col">\n              Models \{\{ sortIcon\('models_queried_count'\) \}\}\n            <\/th>/g, `<th class="ms-th ms-th-sortable" @click="toggleSort('judge_model')" scope="col">\n              Judge {{ sortIcon('judge_model') }}\n            </th>`);
content = content.replace(/<th class="ms-th ms-th-sortable ms-th-num" @click="toggleSort\('winner_score'\)" scope="col">\n              Score \{\{ sortIcon\('winner_score'\) \}\}\n            <\/th>/g, '');

// Table rows
content = content.replace(/<td class="ms-td ms-td-num">\n                \{\{ r\.models_queried_count \}\}\n              <\/td>/g, `<td class="ms-td ms-td-judge">\n                <span class="ms-judge-name">{{ shortModel(r.judge_model) }}</span>\n              </td>`);
content = content.replace(/<td class="ms-td ms-td-num ms-td-score">\n                \{\{ r\.winner_score\.toFixed\(1\) \}\}\n              <\/td>/g, '');
content = content.replace(/<td colspan="6" class="ms-detail-cell">/g, `<td colspan="5" class="ms-detail-cell">`);

// CSS changes
content = content.replace(/\.ms-td-prompt \{\n  max-width: 280px;\n\}/g, `.ms-td-prompt {\n  max-width: 400px;\n}`);
content = content.replace(/\.ms-prompt-text \{\n  display: -webkit-box;\n  -webkit-line-clamp: 2;\n  -webkit-box-orient: vertical;\n  overflow: hidden;\n  line-height: 1\.4;\n\}/g, `.ms-prompt-text {\n  display: -webkit-box;\n  -webkit-line-clamp: 3;\n  -webkit-box-orient: vertical;\n  overflow: hidden;\n  line-height: 1.4;\n}`);
content = content.replace(/\.ms-refresh-btn \{[\s\S]*?\.ms-spinning \{ animation: spin 0\.7s linear infinite; \}\n\n/g, '');
content = content.replace(/\.ms-poll-status \{[\s\S]*?\}\n\n/g, '');

// Update sorting logic
content = content.replace(/case 'models_queried_count':\n        return dir \* \(a\.models_queried_count - b\.models_queried_count\)/g, `case 'judge_model':\n        return dir * (a.judge_model || '').localeCompare(b.judge_model || '')`);

// Update skill explanation
content = content.replace(/<p>\n        <a href="https:\/\/clawhub\.com\/skills\/modelshow" target="_blank" rel="noopener" class="modelshow-link"><strong>ModelShow<\/strong><\/a> is an OpenClaw skill that runs blind comparisons between AI models\. \n        It queries multiple models with the same prompt, hides their identities from the judge model, \n        then ranks them based on response quality\. This eliminates brand bias and reveals which models \n        actually perform best on specific tasks\.\n      <\/p>/g, `<p>\n        <a href="https://clawhub.com/skills/modelshow" target="_blank" rel="noopener" class="modelshow-link"><strong>ModelShow</strong></a> is an OpenClaw skill that runs blind comparisons between AI models. \n        It queries multiple models with an identical prompt, strips away their identities, \n        and has a judge model blindly rank the responses based on objective quality. This architectural de-anonymization \n        removes brand bias and reliably reveals which models actually perform best in the real world.\n      </p>`);

// Table Footer
content = content.replace(/<span class="ms-poll-note">Auto-refreshes every 30s<\/span>/g, `<span class="ms-poll-note">No auto-refresh</span>`); // Maybe remove entirely? Let's just remove the note

content = content.replace(/<span class="ms-poll-note">No auto-refresh<\/span>/g, ``);
content = content.replace(/<span>\{\{ sortedResults\.length \}\} of \{\{ results\.length \}\} result\{\{ results\.length !== 1 \? 's' : '' \}\}<\/span>\n        \n/g, `<span>{{ sortedResults.length }} of {{ results.length }} result{{ results.length !== 1 ? 's' : '' }}</span>`);

fs.writeFileSync('rexuvia-site/src/components/ModelShowResults.vue', content);
