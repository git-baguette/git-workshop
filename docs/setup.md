---
sidebar_position: 2
---

# Setup — Construire le projet TodoCraft

:::info Durée : 15 minutes
Faites ceci avant tout autre module. Tous les TPs s'appuient sur ce projet.
:::

## Ce que le script crée

- Un dépôt Git avec **47 commits** d'historique réaliste
- Un **bug planté** au commit 26 dans `src/utils/sort.js` (vous le trouverez avec bisect)
- Trois **branches en cours** : `feature/dark-mode`, `feature/export-csv`, `feature/auth-v2`
- Une **branche "supprimée"** pour l'exercice reflog
- Un **script de test** pour bisect

## Lancer le setup

```bash
mkdir -p ~/git-workshop && cd ~/git-workshop
```

Copiez-collez le script ci-dessous dans votre terminal. Il tourne en moins de 30 secondes.

```bash
#!/usr/bin/env bash
set -e

echo "🚀 Création de TodoCraft..."

cd ~/git-workshop
rm -rf todocraft
git init -b main todocraft
cd todocraft

git config user.email "workshop@todocraft.io"
git config user.name "TodoCraft Dev"

# ─── Helpers ──────────────────────────────────────────────────────────────────

commit() { git add -A && git commit -m "$1" --quiet; }

# ─── Structure du projet ──────────────────────────────────────────────────────

mkdir -p src/{api,utils,components,auth,ui} tests

# ─── Commit 1-5 : Foundation ──────────────────────────────────────────────────

cat > src/utils/sort.js << 'EOF'
// Ordre des priorités : 0 = le plus urgent
const PRIORITY_ORDER = { high: 0, medium: 1, low: 2 };

export function sortByPriority(tasks) {
  return [...tasks].sort(
    (a, b) => PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]
  );
}

export function filterDone(tasks) {
  return tasks.filter(t => !t.done);
}
EOF
commit "feat(utils): add sortByPriority and filterDone"

cat > src/api/tasks.js << 'EOF'
const BASE = "https://api.todocraft.io/v1";

export async function fetchTasks(filter = {}) {
  const params = new URLSearchParams(filter);
  const res = await fetch(`${BASE}/tasks?${params}`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}
EOF
commit "feat(api): add fetchTasks with filter support"

cat > src/api/tasks.js << 'EOF'
const BASE = "https://api.todocraft.io/v1";

export async function fetchTasks(filter = {}) {
  const params = new URLSearchParams(filter);
  const res = await fetch(`${BASE}/tasks?${params}`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export async function createTask(title, priority = "medium") {
  const res = await fetch(`${BASE}/tasks`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title, priority, done: false }),
  });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export async function updateTask(id, patch) {
  const res = await fetch(`${BASE}/tasks/${id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(patch),
  });
  return res.json();
}

export async function deleteTask(id) {
  return fetch(`${BASE}/tasks/${id}`, { method: "DELETE" });
}
EOF
commit "feat(api): add createTask, updateTask, deleteTask"

cat > src/auth/login.js << 'EOF'
export async function login(email, password) {
  if (!email || !password) throw new Error("Identifiants requis");
  const res = await fetch("/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  if (!res.ok) throw new Error("Identifiants invalides");
  const { token, refreshToken } = await res.json();
  sessionStorage.setItem("token", token);
  sessionStorage.setItem("refreshToken", refreshToken);
  return token;
}

export function logout() {
  sessionStorage.clear();
  window.location.href = "/login";
}
EOF
commit "feat(auth): add login and logout"

cat > src/components/TaskList.js << 'EOF'
import { sortByPriority, filterDone } from "../utils/sort.js";

export function TaskList({ tasks, showDone = false }) {
  const filtered = showDone ? tasks : filterDone(tasks);
  const sorted   = sortByPriority(filtered);
  return sorted.map(t =>
    `[${t.priority.toUpperCase()}] ${t.done ? "✓" : "○"} ${t.title}`
  ).join("\n");
}
EOF
commit "feat(ui): add TaskList component"

# ─── Commit 6-10 : Features ───────────────────────────────────────────────────

cat > src/utils/search.js << 'EOF'
export function searchTasks(tasks, query) {
  if (!query) return tasks;
  const q = query.toLowerCase();
  return tasks.filter(t =>
    t.title.toLowerCase().includes(q) ||
    (t.description ?? "").toLowerCase().includes(q)
  );
}
EOF
commit "feat(search): add full-text search helper"

cat > src/utils/export.js << 'EOF'
export function tasksToCSV(tasks) {
  const header = "id,title,priority,done";
  const rows = tasks.map(t =>
    `${t.id},"${t.title.replace(/"/g, '""')}",${t.priority},${t.done}`
  );
  return [header, ...rows].join("\n");
}

export function downloadCSV(content, filename = "tasks.csv") {
  const blob = new Blob([content], { type: "text/csv;charset=utf-8;" });
  const url  = URL.createObjectURL(blob);
  const a    = Object.assign(document.createElement("a"), { href: url, download: filename });
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}
EOF
commit "feat(export): add CSV export and download helper"

cat > src/utils/theme.js << 'EOF'
const KEY = "todocraft-theme";

export function getTheme()       { return localStorage.getItem(KEY) ?? "light"; }
export function setTheme(theme)  { localStorage.setItem(KEY, theme); document.documentElement.dataset.theme = theme; }
export function toggleTheme()    { setTheme(getTheme() === "light" ? "dark" : "light"); }
EOF
commit "feat(theme): add theme system (light/dark)"

cat > src/auth/refresh.js << 'EOF'
export async function refreshAccessToken() {
  const refreshToken = sessionStorage.getItem("refreshToken");
  if (!refreshToken) throw new Error("No refresh token");
  const res = await fetch("/api/auth/refresh", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refreshToken }),
  });
  if (!res.ok) {
    sessionStorage.clear();
    throw new Error("Session expirée");
  }
  const { token } = await res.json();
  sessionStorage.setItem("token", token);
  return token;
}
EOF
commit "feat(auth): add JWT token refresh"

cat > src/utils/keyboard.js << 'EOF'
const shortcuts = new Map();

export function registerShortcut(combo, handler) {
  shortcuts.set(combo.toLowerCase(), handler);
}

export function initKeyboard() {
  document.addEventListener("keydown", (e) => {
    if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") return;
    const combo = [e.ctrlKey && "ctrl", e.shiftKey && "shift", e.key.toLowerCase()]
      .filter(Boolean).join("+");
    shortcuts.get(combo)?.();
  });
}
EOF
commit "feat(keyboard): add keyboard shortcut manager"

# ─── Commit 11-15 : Plus de features ─────────────────────────────────────────

cat > src/utils/groupBy.js << 'EOF'
export function groupByPriority(tasks) {
  return tasks.reduce((acc, t) => {
    (acc[t.priority] ??= []).push(t);
    return acc;
  }, {});
}

export function groupByDate(tasks) {
  return tasks.reduce((acc, t) => {
    const day = new Date(t.createdAt).toDateString();
    (acc[day] ??= []).push(t);
    return acc;
  }, {});
}
EOF
commit "feat(utils): add groupByPriority and groupByDate"

cat > src/api/http.js << 'EOF'
import { refreshAccessToken } from "../auth/refresh.js";

async function request(url, options = {}) {
  const token = sessionStorage.getItem("token");
  const res = await fetch(url, {
    ...options,
    headers: { Authorization: `Bearer ${token}`, ...options.headers },
  });
  if (res.status === 401) {
    await refreshAccessToken();
    return request(url, options); // retry once
  }
  return res;
}

export const http = { get: (u) => request(u), post: (u, b) => request(u, { method: "POST", body: JSON.stringify(b), headers: { "Content-Type": "application/json" } }) };
EOF
commit "refactor(api): extract authenticated HTTP client"

cat > src/components/TaskForm.js << 'EOF'
export function TaskForm({ onSubmit }) {
  return {
    render() {
      return `
        <form id="task-form">
          <input name="title" placeholder="Nouvelle tâche..." required />
          <select name="priority">
            <option value="high">Haute</option>
            <option value="medium" selected>Moyenne</option>
            <option value="low">Basse</option>
          </select>
          <button type="submit">Ajouter</button>
        </form>`;
    },
    mount(el) {
      el.querySelector("#task-form").addEventListener("submit", (e) => {
        e.preventDefault();
        const data = Object.fromEntries(new FormData(e.target));
        onSubmit(data);
      });
    },
  };
}
EOF
commit "feat(ui): add TaskForm component"

cat > src/utils/notifications.js << 'EOF'
export async function requestPermission() {
  if (!("Notification" in window)) return false;
  const perm = await Notification.requestPermission();
  return perm === "granted";
}

export function notify(title, body, icon = "/icons/icon-192.png") {
  if (Notification.permission !== "granted") return;
  new Notification(title, { body, icon });
}
EOF
commit "feat(notifications): add browser notification helper"

cat > src/utils/storage.js << 'EOF'
export function saveLocal(key, value) {
  localStorage.setItem(key, JSON.stringify(value));
}

export function loadLocal(key, fallback = null) {
  try {
    const raw = localStorage.getItem(key);
    return raw === null ? fallback : JSON.parse(raw);
  } catch {
    return fallback;
  }
}
EOF
commit "feat(storage): add typed localStorage helpers"

# ─── Commit 16-20 : Refactoring ───────────────────────────────────────────────

cat > src/components/TaskItem.js << 'EOF'
export function TaskItem({ task, onToggle, onDelete }) {
  const priorityColors = { high: "#e74c3c", medium: "#f39c12", low: "#27ae60" };
  return {
    render: () => `
      <li data-id="${task.id}" style="border-left: 3px solid ${priorityColors[task.priority]}">
        <input type="checkbox" ${task.done ? "checked" : ""} />
        <span class="${task.done ? "done" : ""}">${task.title}</span>
        <button class="delete">🗑</button>
      </li>`,
    mount(el) {
      el.querySelector("input").addEventListener("change", () => onToggle(task.id));
      el.querySelector(".delete").addEventListener("click", () => onDelete(task.id));
    },
  };
}
EOF
commit "refactor(ui): split TaskItem out of TaskList"

echo "/* TodoCraft base styles */" > src/ui/base.css
echo "body { font-family: system-ui, sans-serif; margin: 0; }" >> src/ui/base.css
echo "[data-theme=dark] { background: #1a1a2e; color: #e0e0e0; }" >> src/ui/base.css
commit "feat(ui): add base styles with dark mode CSS variables"

cat > src/utils/debounce.js << 'EOF'
export function debounce(fn, delay = 300) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delay);
  };
}
EOF
commit "feat(utils): add debounce utility for search input"

cat > tests/sort.test.js << 'EOF'
// Test manuel — node tests/sort.test.js
import { sortByPriority } from "../src/utils/sort.js";

const tasks = [
  { id: 1, title: "Basse",   priority: "low" },
  { id: 2, title: "Haute",   priority: "high" },
  { id: 3, title: "Moyenne", priority: "medium" },
  { id: 4, title: "Haute 2", priority: "high" },
];

const sorted = sortByPriority(tasks);

console.assert(sorted[0].priority === "high",   `FAIL [0]: attendu high, obtenu ${sorted[0].priority}`);
console.assert(sorted[1].priority === "high",   `FAIL [1]: attendu high, obtenu ${sorted[1].priority}`);
console.assert(sorted[2].priority === "medium", `FAIL [2]: attendu medium, obtenu ${sorted[2].priority}`);
console.assert(sorted[3].priority === "low",    `FAIL [3]: attendu low, obtenu ${sorted[3].priority}`);

console.log("✅ Tests OK — sortByPriority fonctionne correctement");
EOF
commit "test(utils): add sort unit tests"

cat > tests/api.test.js << 'EOF'
// Smoke tests for API layer
import { createTask } from "../src/api/tasks.js";

// Mock fetch
globalThis.fetch = async (url, opts) => ({
  ok: true,
  json: async () => ({ id: 42, ...JSON.parse(opts?.body ?? "{}") }),
});

const task = await createTask("Test task", "high");
console.assert(task.title === "Test task", "FAIL: title mismatch");
console.assert(task.priority === "high",   "FAIL: priority mismatch");
console.log("✅ API tests OK");
EOF
commit "test(api): add createTask smoke test"

# ─── Commit 21-25 : Plus de features ─────────────────────────────────────────

cat > src/api/batch.js << 'EOF'
import { http } from "./http.js";

export async function batchDelete(ids) {
  return http.post("/api/tasks/batch-delete", { ids });
}

export async function batchUpdate(ids, patch) {
  return http.post("/api/tasks/batch-update", { ids, patch });
}
EOF
commit "feat(api): add batch delete and update operations"

cat > src/utils/sort.js << 'EOF'
const PRIORITY_ORDER = { high: 0, medium: 1, low: 2 };

export function sortByPriority(tasks) {
  return [...tasks].sort(
    (a, b) => PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]
  );
}

export function filterDone(tasks) {
  return tasks.filter(t => !t.done);
}

export function sortByDate(tasks) {
  return [...tasks].sort(
    (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
  );
}
EOF
commit "feat(utils): add sortByDate helper"

cat > src/utils/pagination.js << 'EOF'
export function paginate(items, page = 1, perPage = 20) {
  const start = (page - 1) * perPage;
  return {
    items: items.slice(start, start + perPage),
    total: items.length,
    page,
    pages: Math.ceil(items.length / perPage),
    hasNext: start + perPage < items.length,
    hasPrev: page > 1,
  };
}
EOF
commit "feat(utils): add pagination helper"

cat > src/ui/modal.js << 'EOF'
export function createModal(content) {
  const overlay = document.createElement("div");
  overlay.className = "modal-overlay";
  overlay.innerHTML = `<div class="modal">${content}<button class="close">✕</button></div>`;
  document.body.appendChild(overlay);
  overlay.querySelector(".close").onclick = () => overlay.remove();
  return { close: () => overlay.remove() };
}
EOF
commit "feat(ui): add modal component"

cat > src/ui/toast.js << 'EOF'
export function toast(message, type = "info", duration = 3000) {
  const el = document.createElement("div");
  el.className = `toast toast-${type}`;
  el.textContent = message;
  document.body.appendChild(el);
  requestAnimationFrame(() => el.classList.add("visible"));
  setTimeout(() => { el.classList.remove("visible"); setTimeout(() => el.remove(), 300); }, duration);
}
EOF
commit "feat(ui): add toast notification component"

# ─── Commit 26 : LE BUG ───────────────────────────────────────────────────────

cat > src/utils/sort.js << 'EOF'
// BUG: valeurs inversées ! high devrait être 0, pas 2
const PRIORITY_ORDER = { high: 2, medium: 1, low: 0 };

export function sortByPriority(tasks) {
  return [...tasks].sort(
    (a, b) => PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]
  );
}

export function filterDone(tasks) {
  return tasks.filter(t => !t.done);
}

export function sortByDate(tasks) {
  return [...tasks].sort(
    (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
  );
}
EOF
commit "refactor(sort): update priority constants for new design system"

# ─── Commit 27-35 : Features post-bug ────────────────────────────────────────

cat > src/utils/analytics.js << 'EOF'
const events = [];

export function track(name, props = {}) {
  events.push({ name, props, ts: Date.now() });
  if (events.length >= 10) flush();
}

async function flush() {
  if (!events.length) return;
  const batch = events.splice(0);
  await fetch("/api/analytics", { method: "POST", body: JSON.stringify(batch),
    headers: { "Content-Type": "application/json" } }).catch(() => {});
}
EOF
commit "feat(analytics): add event tracking with batched flush"

cat > src/utils/export.js << 'EOF'
export function tasksToCSV(tasks) {
  const header = "id,title,priority,done,createdAt";
  const rows = tasks.map(t =>
    `${t.id},"${t.title.replace(/"/g, '""')}",${t.priority},${t.done},${t.createdAt ?? ""}`
  );
  return [header, ...rows].join("\n");
}

export async function tasksToJSON(tasks) {
  return JSON.stringify(tasks, null, 2);
}

export function downloadCSV(content, filename = "tasks.csv") {
  const blob = new Blob([content], { type: "text/csv;charset=utf-8;" });
  const url  = URL.createObjectURL(blob);
  const a    = Object.assign(document.createElement("a"), { href: url, download: filename });
  document.body.appendChild(a);
  a.click();
  a.remove();
}
EOF
commit "feat(export): add JSON export and createdAt column in CSV"

cat > src/auth/login.js << 'EOF'
export async function login(email, password) {
  if (!email?.trim()) throw new Error("Email requis");
  if (!password)      throw new Error("Mot de passe requis");
  if (!/\S+@\S+\.\S+/.test(email)) throw new Error("Email invalide");
  const res = await fetch("/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: email.trim(), password }),
  });
  if (!res.ok) throw new Error("Identifiants invalides");
  const { token, refreshToken } = await res.json();
  sessionStorage.setItem("token", token);
  sessionStorage.setItem("refreshToken", refreshToken);
  return token;
}
export function logout() { sessionStorage.clear(); window.location.href = "/login"; }
EOF
commit "fix(auth): add email format validation and trim whitespace"

echo "[data-theme=dark] body { background: #0d1117; color: #c9d1d9; }" >> src/ui/base.css
echo "[data-theme=dark] .task-item { border-color: #30363d; }" >> src/ui/base.css
commit "feat(ui): improve dark mode color palette"

cat > src/utils/cache.js << 'EOF'
const store = new Map();

export function memoize(fn, ttl = 60_000) {
  return async (...args) => {
    const key = JSON.stringify(args);
    const hit = store.get(key);
    if (hit && Date.now() - hit.ts < ttl) return hit.value;
    const value = await fn(...args);
    store.set(key, { value, ts: Date.now() });
    return value;
  };
}

export function invalidateCache(keyPrefix) {
  for (const k of store.keys()) {
    if (k.startsWith(keyPrefix)) store.delete(k);
  }
}
EOF
commit "feat(cache): add memoize utility with TTL"

cat > src/utils/offline.js << 'EOF'
const QUEUE_KEY = "todocraft-offline-queue";

export function queueAction(action) {
  const queue = JSON.parse(localStorage.getItem(QUEUE_KEY) ?? "[]");
  queue.push({ ...action, ts: Date.now() });
  localStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
}

export async function replayQueue() {
  const queue = JSON.parse(localStorage.getItem(QUEUE_KEY) ?? "[]");
  localStorage.removeItem(QUEUE_KEY);
  for (const action of queue) {
    await fetch(action.url, action.options).catch(console.error);
  }
}
EOF
commit "feat(offline): add offline action queue"

cat > docs/api.md << 'EOF'
# API Reference

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/tasks | Fetch all tasks |
| POST | /api/tasks | Create a task |
| PATCH | /api/tasks/:id | Update a task |
| DELETE | /api/tasks/:id | Delete a task |
EOF
commit "docs: add API reference documentation"

cat > src/utils/shortcuts-map.js << 'EOF'
import { registerShortcut } from "./keyboard.js";

export function registerAppShortcuts({ newTask, search, toggleTheme, exportCSV }) {
  registerShortcut("ctrl+k",     search);
  registerShortcut("ctrl+n",     newTask);
  registerShortcut("ctrl+d",     toggleTheme);
  registerShortcut("ctrl+e",     exportCSV);
  registerShortcut("ctrl+shift+a", () => document.querySelector("[name=select-all]")?.click());
}
EOF
commit "feat(keyboard): add app-level shortcut bindings"

cat > src/utils/i18n.js << 'EOF'
const locales = {
  fr: { newTask: "Nouvelle tâche", done: "Terminé", delete: "Supprimer" },
  en: { newTask: "New task",       done: "Done",    delete: "Delete"    },
};

let current = navigator.language.slice(0, 2);
if (!(current in locales)) current = "en";

export const t = (key) => locales[current][key] ?? key;
export const setLocale = (lang) => { current = lang in locales ? lang : "en"; };
EOF
commit "feat(i18n): add basic localization for fr/en"

# ─── Commit 36-40 ─────────────────────────────────────────────────────────────

cat > src/utils/drag.js << 'EOF'
export function enableDragSort(listEl, onReorder) {
  let dragSrc = null;
  listEl.querySelectorAll("[draggable]").forEach(item => {
    item.addEventListener("dragstart", e => { dragSrc = item; e.dataTransfer.effectAllowed = "move"; });
    item.addEventListener("dragover",  e => { e.preventDefault(); e.dataTransfer.dropEffect = "move"; });
    item.addEventListener("drop",      () => {
      if (dragSrc !== item) {
        const items = [...listEl.children];
        const fromIdx = items.indexOf(dragSrc);
        const toIdx   = items.indexOf(item);
        listEl.insertBefore(dragSrc, toIdx < fromIdx ? item : item.nextSibling);
        onReorder(items.map(el => el.dataset.id));
      }
    });
  });
}
EOF
commit "feat(ui): add drag-and-drop task reordering"

cat > src/utils/sync.js << 'EOF'
let ws;

export function connectSync(onUpdate) {
  ws = new WebSocket("wss://api.todocraft.io/sync");
  ws.onmessage = (e) => onUpdate(JSON.parse(e.data));
  ws.onclose   = ()  => setTimeout(() => connectSync(onUpdate), 3000);
}

export function sendSync(event) {
  if (ws?.readyState === WebSocket.OPEN) ws.send(JSON.stringify(event));
}
EOF
commit "feat(sync): add WebSocket real-time sync"

cat > src/utils/undo.js << 'EOF'
const history = [];
const future  = [];

export function execute(action, undo) {
  action();
  history.push(undo);
  future.length = 0;
}

export function undo() { const fn = history.pop(); if (fn) { fn(); future.push(fn); } }
export function redo() { const fn = future.pop(); if (fn) { fn(); history.push(fn); } }
EOF
commit "feat(ui): add undo/redo action history"

cat > src/utils/perf.js << 'EOF'
export function measure(label, fn) {
  const start = performance.now();
  const result = fn();
  console.debug(`[perf] ${label}: ${(performance.now() - start).toFixed(2)}ms`);
  return result;
}
EOF
commit "perf: add performance measurement utility"

cat > src/utils/collab.js << 'EOF'
export function generatePresenceId() {
  return Math.random().toString(36).slice(2, 9);
}

export function broadcastCursor(presenceId, position) {
  sendSync({ type: "cursor", presenceId, position });
}
EOF
commit "feat(collab): add collaborative presence utilities"

# ─── Commit 41-47 ─────────────────────────────────────────────────────────────

cat > src/utils/analytics.js << 'EOF'
const events = [];
let flushTimer;

export function track(name, props = {}) {
  events.push({ name, props, ts: Date.now(), session: sessionStorage.getItem("token")?.slice(-8) });
  clearTimeout(flushTimer);
  flushTimer = setTimeout(flush, 2000);
}

async function flush() {
  if (!events.length) return;
  const batch = events.splice(0);
  await fetch("/api/analytics/batch", {
    method: "POST",
    body: JSON.stringify(batch),
    headers: { "Content-Type": "application/json" },
  }).catch(console.error);
}
EOF
commit "feat(analytics): improve batching with debounced flush"

cat > src/ui/dashboard.js << 'EOF'
import { groupByPriority } from "../utils/groupBy.js";

export function renderDashboard(tasks) {
  const groups = groupByPriority(tasks);
  const done   = tasks.filter(t => t.done).length;
  return `
    <section class="dashboard">
      <div class="stat">Total : ${tasks.length}</div>
      <div class="stat">Terminées : ${done} (${Math.round(done / tasks.length * 100)}%)</div>
      <div class="stat">Haute : ${(groups.high ?? []).length}</div>
      <div class="stat">Moyenne : ${(groups.medium ?? []).length}</div>
      <div class="stat">Basse : ${(groups.low ?? []).length}</div>
    </section>`;
}
EOF
commit "feat(ui): add analytics dashboard component"

cat > src/utils/export.js << 'EOF'
export function tasksToCSV(tasks) {
  if (!tasks.length) return "id,title,priority,done,createdAt\n(aucune tâche)";
  const header = "id,title,priority,done,createdAt";
  const rows = tasks.map(t =>
    `${t.id},"${t.title.replace(/"/g, '""')}",${t.priority},${t.done},${t.createdAt ?? ""}`
  );
  return [header, ...rows].join("\n");
}
export async function tasksToJSON(tasks) { return JSON.stringify(tasks, null, 2); }
export function downloadCSV(content, filename = "tasks.csv") {
  const blob = new Blob([content], { type: "text/csv;charset=utf-8;" });
  const url  = URL.createObjectURL(blob);
  const a    = Object.assign(document.createElement("a"), { href: url, download: filename });
  document.body.appendChild(a); a.click(); a.remove();
}
EOF
commit "fix(export): handle empty task list gracefully in CSV"

cat >> src/utils/keyboard.js << 'EOF'

export function listShortcuts() {
  return [...shortcuts.entries()].map(([k, v]) => ({ combo: k, name: v.name ?? "?" }));
}
EOF
commit "feat(keyboard): add shortcut discovery/listing"

cat > src/utils/validation.js << 'EOF'
export function validateTask(data) {
  const errors = [];
  if (!data.title?.trim())             errors.push("Le titre est requis");
  if (data.title?.length > 200)        errors.push("Titre trop long (max 200 caractères)");
  if (!["high","medium","low"].includes(data.priority)) errors.push("Priorité invalide");
  return errors;
}
EOF
commit "feat(validation): add task input validation"

cat > src/utils/filter.js << 'EOF'
export function applyFilters(tasks, filters = {}) {
  let result = [...tasks];
  if (filters.priority)    result = result.filter(t => t.priority === filters.priority);
  if (filters.done !== undefined) result = result.filter(t => t.done === filters.done);
  if (filters.search)      result = result.filter(t => t.title.toLowerCase().includes(filters.search.toLowerCase()));
  if (filters.since)       result = result.filter(t => new Date(t.createdAt) >= new Date(filters.since));
  return result;
}
EOF
commit "feat(filter): add composable multi-filter utility"

echo "1.0.0" > VERSION
commit "chore: release v1.0.0"

# ─── Branches pour les exercices ──────────────────────────────────────────────

MAIN_HASH=$(git rev-parse HEAD)

# Branch feature/dark-mode (partiellement développée)
git checkout -b feature/dark-mode --quiet
cat > src/ui/darkmode.js << 'EOF'
import { getTheme, setTheme } from "../utils/theme.js";

export function mountDarkModeToggle(buttonEl) {
  buttonEl.textContent = getTheme() === "dark" ? "☀️" : "🌙";
  buttonEl.addEventListener("click", () => {
    const next = getTheme() === "light" ? "dark" : "light";
    setTheme(next);
    buttonEl.textContent = next === "dark" ? "☀️" : "🌙";
    // TODO: animer la transition avec une classe CSS
  });
}
EOF
git add -A && git commit -m "feat(ui): add dark mode toggle button component" --quiet
# Modification non-committée intentionnelle (travail en cours)
cat >> src/ui/darkmode.js << 'EOF'

export function preloadTheme() {
  // Appelé dans <head> pour éviter le flash
  const theme = localStorage.getItem("todocraft-theme") ?? "light";
  document.documentElement.dataset.theme = theme;
}
EOF
git checkout main --quiet

# Branch feature/export-csv
git checkout -b feature/export-csv --quiet
cat > src/ui/ExportButton.js << 'EOF'
import { tasksToCSV, downloadCSV } from "../utils/export.js";

export function ExportButton({ getTasks }) {
  const btn = document.createElement("button");
  btn.className = "btn-export";
  btn.textContent = "⬇ Export CSV";
  btn.addEventListener("click", () => {
    const csv = tasksToCSV(getTasks());
    downloadCSV(csv, `todocraft-${new Date().toISOString().slice(0,10)}.csv`);
  });
  return btn;
}
EOF
git add -A && git commit -m "feat(ui): add ExportButton component with dated filename" --quiet
git checkout main --quiet

# Branch feature/auth-v2 — sera "supprimée" pour l'exercice reflog
git checkout -b feature/auth-v2 --quiet
cat > src/auth/oauth.js << 'EOF'
export function initiateOAuth(provider = "github") {
  const params = new URLSearchParams({
    client_id: "todocraft-app",
    redirect_uri: `${location.origin}/oauth/callback`,
    scope: "read:user user:email",
    state: crypto.randomUUID(),
  });
  location.href = `https://github.com/login/oauth/authorize?${params}`;
}

export async function handleOAuthCallback(code, state) {
  const res = await fetch("/api/auth/oauth", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ code, state }),
  });
  if (!res.ok) throw new Error("OAuth callback failed");
  return res.json();
}
EOF
git add -A && git commit -m "feat(auth): add OAuth2 GitHub login flow" --quiet

AUTH_V2_HASH=$(git rev-parse HEAD)
git checkout main --quiet

# Simuler la suppression de la branche (exercice reflog)
git branch -D feature/auth-v2

# ─── Script de test bisect ────────────────────────────────────────────────────

cat > bisect-test.sh << 'EOF'
#!/bin/bash
# Script pour git bisect run
# Exit 0 = commit bon, Exit 1 = commit mauvais, Exit 125 = skip

# Vérifier que le fichier sort.js existe
if [ ! -f "src/utils/sort.js" ]; then
  exit 125  # Pas encore créé à ce stade, skip
fi

# Lancer le test
node --input-type=module << 'JSEOF'
import { readFileSync } from "fs";

const code = readFileSync("src/utils/sort.js", "utf8");
const match = code.match(/PRIORITY_ORDER\s*=\s*\{([^}]+)\}/);
if (!match) process.exit(125);

const obj = {};
match[1].replace(/(\w+)\s*:\s*(\d+)/g, (_, k, v) => { obj[k] = parseInt(v); });

// high doit avoir la PLUS PETITE valeur (trié en premier)
const isCorrect = obj.high < obj.medium && obj.medium < obj.low;
process.exit(isCorrect ? 0 : 1);
JSEOF
EOF
chmod +x bisect-test.sh
git add bisect-test.sh
git commit -m "chore: add bisect test script" --quiet

git checkout main --quiet

echo ""
echo "✅ TodoCraft prêt !"
echo ""
git log --oneline | wc -l | xargs echo "   Commits :"
git branch | xargs echo "   Branches :"
echo ""
echo "   Bug planté au commit : $(git log --oneline | grep 'update priority constants' | awk '{print $1}')"
echo "   Script bisect        : ./bisect-test.sh"
echo ""
echo "👉 Vérification rapide :"
node --input-type=module << 'EOF'
import { readFileSync } from "fs";
const code = readFileSync("src/utils/sort.js", "utf8");
const hasBug = code.includes("high: 2");
console.log(hasBug ? "   ⚠️  Bug confirmé dans sort.js (high: 2)" : "   ✅ Pas de bug détecté");
EOF
```

## Vérifier le setup

```bash
cd ~/git-workshop/todocraft

# Nombre de commits
git log --oneline | wc -l
# 49 (47 + bisect-test.sh + setup commit)

# État des branches
git branch -a
# * main
#   feature/dark-mode
#   feature/export-csv

# Le bug est bien là
grep "high:" src/utils/sort.js
# high: 2,    ← valeur incorrecte (devrait être 0)

# Lancer les tests — ils doivent ÉCHOUER
node tests/sort.test.js
# AssertionError : ...
```

## Aide-mémoire du projet

| Élément              | Emplacement                 | Rôle dans le workshop |
| -------------------- | --------------------------- | --------------------- |
| `src/utils/sort.js`  | Fichier avec le bug         | Module Bisect         |
| `tests/sort.test.js` | Script de test              | Module Bisect         |
| `bisect-test.sh`     | Script bisect automatisé    | Module Bisect         |
| `feature/dark-mode`  | Branche en cours            | Module Worktrees      |
| `feature/export-csv` | Branche en cours            | Module Worktrees      |
| `feature/auth-v2`    | **Supprimée** — à retrouver | Module Reflog         |
| Commit 26            | Bug `PRIORITY_ORDER`        | Module Bisect         |
