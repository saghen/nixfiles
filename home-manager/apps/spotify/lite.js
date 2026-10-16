// lite: turn off Spotify's heavier optional features through its own remote-config overrides
// (the same mechanism as Spotify's developer "experimental features" menu), so React never
// renders them. Core playback, library, search, lyrics, queue, Jam and DJ are untouched.
//
// Overrides persist in Spotify's local storage; web overrides need one reload to apply, which
// this does once after setting them (guarded against reload loops).
(async function lite() {
  const OFF = [
    // Home "Big Cards" feed: hover-started audio/video previews, transcripts, watch feed
    "enableFeedBaselineAudioPreviews",
    "enableFeedBaselineVideoPreviews",
    "enableFeedBaselineTranscripts",
    "enableWatchFeed",
    "enableWatchFeedEntityPages",
    "enableWatchFeedPreviewReporting",
    "enable1DCardPreviewReporting",
    "enableAutoPlayOnLoad",
    // video surfaces
    "enableNPVideosV2",
    "enableNowPlayingBarVideo",
    "enableRelatedVideos",
    "enableUnmappedVideos",
    "enableVideoFirstPlaylist",
    "enableVideoThumbnailScrubbing",
    "enableBetamaxSdkVideoOnVideoSai",
    "enableImprovedCinemaModeCanvas",
    "enableImprovedCinemaModeOpenOnMusicVideoPlayback",
    "enablePiPMiniPlayerVideo",
    // promos and noise
    "enableInAppMessaging",
    "enableNonUserTriggeredPopovers",
    "enableTheStageDesktop",
    "enableConcertCampaignCard",
    "enableWaveformPreviewColumn",
    "enableUserCommentsForEpisodes",
  ];
  const GUARD = "lite:override-reloads";

  while (!window.Spicetify?.Platform?.RemoteConfigDebugAPI) await new Promise((r) => setTimeout(r, 100));

  // Canvas (looping track videos in the Now Playing view): same as Settings > Canvas off
  const ps = Spicetify.Platform.ProductStateAPI;
  try {
    const values = await ps.productStateApi.getValues();
    if (values?.pairs?.["canvas-disabled"] !== "1") await ps.setValues({ "canvas-disabled": "1" });
  } catch (e) {
    console.warn("[lite] could not disable canvas", e);
  }

  const api = Spicetify.Platform.RemoteConfigDebugAPI;
  const props = await api.getProperties();
  const todo = props.filter((p) => p.source === "web" && p.type === "boolean" && OFF.includes(p.name) && p.localValue !== false);
  if (!todo.length) {
    localStorage.removeItem(GUARD);
    return;
  }
  const tries = Number(localStorage.getItem(GUARD) || 0);
  if (tries >= 2) {
    console.warn("[lite] overrides did not stick, not reloading again:", todo.map((p) => p.name));
    return;
  }
  localStorage.setItem(GUARD, String(tries + 1));
  await api.setOverrides(todo.map((p) => ({ ref: { source: p.source, type: p.type, name: p.name }, value: false })));
  location.reload();
})();
