<template>
  <div data-testid="not-found-page">
    <h1 class="text-h5 mb-2">Page not found</h1>
    <p class="text-body-1 mb-4">The address you opened does not match a screen in xOpti.</p>
    <v-btn :to="{ path: '/' }" color="primary" variant="tonal">Go to home</v-btn>
  </div>
</template>
