import { ref } from 'vue'
import { defineStore } from 'pinia'

/** Shell-level UI state that is not owned by any single page. */
export const useShellStore = defineStore('shell', () => {
  /** Full path of a lazy route whose module failed to load; null when healthy. */
  const chunkErrorPath = ref<string | null>(null)

  function setChunkError(path: string): void {
    chunkErrorPath.value = path
  }

  function clearChunkError(): void {
    chunkErrorPath.value = null
  }

  return { chunkErrorPath, setChunkError, clearChunkError }
})
