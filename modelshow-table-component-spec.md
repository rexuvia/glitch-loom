# ModelShowTable Component Specification

## Component Name
`ModelShowTable.vue`

## Location
`/home/ubuntu/.openclaw/workspace/rexuvia-site/src/components/ModelShowTable.vue`

## Props
None (self-contained)

## Emits
None

## State (Composition API)
```typescript
import { ref, computed, onMounted, onUnmounted } from 'vue'

interface ResultMetadata {
  id: string
  slug: string
  timestamp: string
  prompt: string
  prompt_preview: string
  models_queried: string[]
  models_queried_count: number
  winner_model: string
  winner_score: number
  total_duration_ms: number
  json_url: string
  md_url: string
  tags?: string[]
}

interface FullResult {
  meta: {
    timestamp: string
    prompt: string
    models_queried: string[]
    judge_model: string
    judging_mode: string
  }
  results: Array<{
    rank: number
    model: string
    model_alias: string
    score: number
    response: string
    assessment: string
  }>
  judge_analysis: string
  anonymization_map: Record<string, string>
  metadata: {
    total_duration_ms: number
    successful_models: number
    failed_models: number
    timed_out_models: string[]
  }
}

// Reactive state
const results = ref<ResultMetadata[]>([])
const loading = ref(false)
const error = ref<string|null>(null)
const selectedResultId = ref<string|null>(null)
const selectedResultFull = ref<FullResult|null>(null)
const sortBy = ref<'timestamp' | 'winner_score' | 'models_queried_count' | 'total_duration_ms'>('timestamp')
const sortOrder = ref<'asc' | 'desc'>('desc')
const filterModel = ref('')
const filterDateFrom = ref('')
const filterDateTo = ref('')
const lastPollTime = ref<Date|null>(null)
const pollInterval = ref<NodeJS.Timeout|null>(null)

// Computed
const filteredResults = computed(() => {
  let filtered = [...results.value]
  
  if (filterModel.value) {
    filtered = filtered.filter(r => 
      r.models_queried.some(m => 
        m.toLowerCase().includes(filterModel.value.toLowerCase())
      )
    )
  }
  
  if (filterDateFrom.value) {
    const from = new Date(filterDateFrom.value)
    filtered = filtered.filter(r => new Date(r.timestamp) >= from)
  }
  
  if (filterDateTo.value) {
    const to = new Date(filterDateTo.value)
    filtered = filtered.filter(r => new Date(r.timestamp) <= to)
  }
  
  return filtered
})

const sortedResults = computed(() => {
  const order = sortOrder.value === 'asc' ? 1 : -1
  return [...filteredResults.value].sort((a, b) => {
    if (sortBy.value === 'timestamp') {
      return order * (new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime())
    }
    if (sortBy.value === 'winner_score') {
      return order * (a.winner_score - b.winner_score)
    }
    if (sortBy.value === 'models_queried_count') {
      return order * (a.models_queried_count - b.models_queried_count)
    }
    if (sortBy.value === 'total_duration_ms') {
      return order * (a.total_duration_ms - b.total_duration_ms)
    }
    return 0
  })
})

const lastUpdatedText = computed(() => {
  if (!lastPollTime.value) return 'Never'
  const diff = Date.now() - lastPollTime.value.getTime()
  const seconds = Math.floor(diff / 1000)
  if (seconds < 60) return `${seconds}s ago`
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  return `${hours}h ago`
})
```

## Methods
```typescript
// Fetch index.json
async function fetchIndex() {
  loading.value = true
  error.value = null
  try {
    const response = await fetch('/modelshow-results/index.json')
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    const data = await response.json()
    
    // Check for new results
    const currentIds = new Set(results.value.map(r => r.id))
    const newEntries = data.results.filter((r: ResultMetadata) => !currentIds.has(r.id))
    
    results.value = data.results
    lastPollTime.value = new Date()
    
    // Load full data for any new entries (optional)
    // for (const entry of newEntries) {
    //   await fetchResult(entry.id)
    // }
  } catch (err) {
    error.value = err instanceof Error ? err.message : 'Failed to load results'
  } finally {
    loading.value = false
  }
}

// Fetch individual result JSON
async function fetchResult(id: string) {
  try {
    const response = await fetch(`/modelshow-results/${id}.json`)
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    const data = await response.json()
    selectedResultFull.value = data
    return data
  } catch (err) {
    error.value = `Failed to load result ${id}: ${err instanceof Error ? err.message : 'Unknown error'}`
    return null
  }
}

// Toggle sort column/order
function toggleSort(column: typeof sortBy.value) {
  if (sortBy.value === column) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortBy.value = column
    sortOrder.value = 'desc' // newest/highest first by default
  }
}

// Expand/collapse row
async function toggleExpand(id: string) {
  if (selectedResultId.value === id) {
    selectedResultId.value = null
    selectedResultFull.value = null
  } else {
    selectedResultId.value = id
    if (!selectedResultFull.value || selectedResultFull.value.meta.timestamp !== id) {
      await fetchResult(id)
    }
  }
}

// Start polling
function startPolling(intervalMs = 30000) {
  stopPolling()
  pollInterval.value = setInterval(fetchIndex, intervalMs)
}

// Stop polling
function stopPolling() {
  if (pollInterval.value) {
    clearInterval(pollInterval.value)
    pollInterval.value = null
  }
}

// Format duration
function formatDuration(ms: number): string {
  const seconds = Math.floor(ms / 1000)
  if (seconds < 60) return `${seconds}s`
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}m ${remainingSeconds}s`
}

// Format timestamp
function formatTimestamp(iso: string): string {
  return new Date(iso).toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Format model list
function formatModels(models: string[]): string {
  return models.map(m => m.split('/').pop()).join(', ')
}
```

## Lifecycle Hooks
```typescript
onMounted(() => {
  fetchIndex()
  startPolling()
})

onUnmounted(() => {
  stopPolling()
})
```

## Template Structure
```vue
<template>
  <section class="modelshow-section">
    <h2 class="section-title">ModelShow Comparisons</h2>
    <p class="section-subtitle">
      Live results from blind model comparisons.
      <span v-if="lastPollTime">Last updated {{ lastUpdatedText }}</span>
    </p>

    <!-- Controls -->
    <div class="controls">
      <div class="search-filter">
        <input
          v-model="filterModel"
          placeholder="Filter by model..."
          type="text"
          class="filter-input"
        />
        <input
          v-model="filterDateFrom"
          type="date"
          placeholder="From"
          class="filter-date"
        />
        <input
          v-model="filterDateTo"
          type="date"
          placeholder="To"
          class="filter-date"
        />
        <button @click="fetchIndex" class="refresh-btn">
          ↻ Refresh
        </button>
      </div>
    </div>

    <!-- Error -->
    <div v-if="error" class="error-banner">
      {{ error }}
    </div>

    <!-- Loading -->
    <div v-if="loading && results.length === 0" class="loading">
      Loading comparison results...
    </div>

    <!-- Table -->
    <div v-else class="results-table">
      <table>
        <thead>
          <tr>
            <th @click="toggleSort('timestamp')">
              Timestamp
              <span v-if="sortBy === 'timestamp'">{{ sortOrder === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th>Prompt</th>
            <th @click="toggleSort('models_queried_count')">
              Models
              <span v-if="sortBy === 'models_queried_count'">{{ sortOrder === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th @click="toggleSort('winner_score')">
              Winner / Score
              <span v-if="sortBy === 'winner_score'">{{ sortOrder === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th @click="toggleSort('total_duration_ms')">
              Duration
              <span v-if="sortBy === 'total_duration_ms'">{{ sortOrder === 'asc' ? '↑' : '↓' }}</span>
            </th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="result in sortedResults" :key="result.id">
            <td>{{ formatTimestamp(result.timestamp) }}</td>
            <td>{{ result.prompt_preview }}</td>
            <td>{{ result.models_queried_count }} ({{ formatModels(result.models_queried) }})</td>
            <td>
              <strong>{{ result.winner_model.split('/').pop() }}</strong>
              <br>
              <small>{{ result.winner_score.toFixed(1) }}/10</small>
            </td>
            <td>{{ formatDuration(result.total_duration_ms) }}</td>
            <td>
              <button @click="toggleExpand(result.id)" class="expand-btn">
                {{ selectedResultId === result.id ? 'Collapse' : 'Expand' }}
              </button>
              <a :href="result.json_url" target="_blank" class="json-link">JSON</a>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Empty state -->
      <div v-if="results.length === 0" class="empty-state">
        No comparison results yet.
      </div>
    </div>

    <!-- Expanded detail view -->
    <div v-if="selectedResultFull" class="detail-view">
      <h3>Detailed Comparison</h3>
      <div class="detail-content">
        <div class="prompt">
          <strong>Prompt:</strong> {{ selectedResultFull.meta.prompt }}
        </div>
        <div class="rankings">
          <h4>Rankings</h4>
          <div v-for="r in selectedResultFull.results" :key="r.rank" class="ranking-item">
            <span class="medal">{{ getMedal(r.rank) }}</span>
            <strong>{{ r.model.split('/').pop() }}</strong>
            <span class="score">{{ r.score.toFixed(1) }}/10</span>
            <p class="assessment">{{ r.assessment }}</p>
            <details class="response">
              <summary>Response</summary>
              <pre>{{ r.response }}</pre>
            </details>
          </div>
        </div>
        <div class="judge-analysis">
          <h4>Judge's Analysis</h4>
          <p>{{ selectedResultFull.judge_analysis }}</p>
        </div>
        <div class="links">
          <a :href="selectedResultFull.meta.json_url" target="_blank">View raw JSON</a>
          <a :href="selectedResultFull.meta.md_url" target="_blank">View Markdown report</a>
        </div>
      </div>
    </div>
  </section>
</template>
```

## Styles
Match existing site design (dark theme, starry background). Use CSS classes consistent with existing `App.vue`.

Add to `App.vue` styles section:
```css
.modelshow-section {
  padding: 36px 0;
}

.controls {
  margin-bottom: 20px;
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.filter-input, .filter-date {
  padding: 8px 12px;
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(255,255,255,0.05);
  color: #e0e0e0;
  border-radius: 4px;
}

.refresh-btn {
  padding: 8px 16px;
  background: rgba(232, 116, 97, 0.2);
  border: 1px solid rgba(232, 116, 97, 0.5);
  color: #e87461;
  border-radius: 4px;
  cursor: pointer;
}

.refresh-btn:hover {
  background: rgba(232, 116, 97, 0.3);
}

.results-table table {
  width: 100%;
  border-collapse: collapse;
  border: 1px solid rgba(255,255,255,0.08);
}

.results-table th {
  text-align: left;
  padding: 12px;
  border-bottom: 1px solid rgba(255,255,255,0.08);
  cursor: pointer;
  user-select: none;
}

.results-table td {
  padding: 12px;
  border-bottom: 1px solid rgba(255,255,255,0.04);
}

.results-table tr:hover {
  background: rgba(255,255,255,0.03);
}

.expand-btn, .json-link {
  padding: 4px 8px;
  margin-right: 8px;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.1);
  color: #e0e0e0;
  border-radius: 4px;
  text-decoration: none;
  font-size: 0.85rem;
}

.expand-btn:hover, .json-link:hover {
  background: rgba(255,255,255,0.1);
}

.detail-view {
  margin-top: 30px;
  padding: 20px;
  border-left: 3px solid rgba(232, 116, 97, 0.5);
  background: rgba(255,255,255,0.02);
  border-radius: 0 8px 8px 0;
}

.ranking-item {
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid rgba(255,255,255,0.05);
}

.medal {
  font-size: 1.5em;
  margin-right: 10px;
}

.score {
  margin-left: 10px;
  color: #e87461;
}

.response summary {
  cursor: pointer;
  color: #888;
}

.response pre {
  background: rgba(0,0,0,0.3);
  padding: 10px;
  border-radius: 4px;
  overflow-x: auto;
}

.error-banner {
  background: rgba(255, 50, 50, 0.1);
  border: 1px solid rgba(255, 50, 50, 0.3);
  color: #ff6666;
  padding: 12px;
  border-radius: 4px;
  margin-bottom: 20px;
}

.loading, .empty-state {
  text-align: center;
  padding: 40px;
  color: #777;
  font-style: italic;
}
```

## Integration into App.vue
Add to `App.vue` template after the Games section:
```vue
<!-- ModelShow Results Section -->
<ModelShowTable />
```

Add import:
```vue
<script setup>
import ModelShowTable from './components/ModelShowTable.vue'
// ... existing imports
</script>
```

## Dependencies
None beyond Vue 3 and existing dependencies.

## Testing
- Unit tests with vitest (optional)
- Manual testing with mock index.json
- Integration with real data