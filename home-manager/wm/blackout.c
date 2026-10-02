// Covers a single output with a black layer-shell overlay until killed.
// Usage: blackout <output-name>

#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <wayland-client.h>
#include "viewporter-client-protocol.h"
#include "wlr-layer-shell-unstable-v1-client-protocol.h"

static struct wl_compositor *compositor;
static struct wl_shm *shm;
static struct wp_viewporter *viewporter;
static struct zwlr_layer_shell_v1 *layer_shell;
static struct wl_output *output;
static struct wl_surface *surface;
static struct wp_viewport *viewport;
static struct wl_buffer *buffer;
static const char *output_name;

static void noop() {}

static void output_name_cb(void *data, struct wl_output *o, const char *name) {
  if (!strcmp(name, output_name)) output = o;
}

static const struct wl_output_listener output_listener = {
    .geometry = noop, .mode = noop, .done = noop, .scale = noop, .name = output_name_cb, .description = noop};

static void global(void *data, struct wl_registry *r, uint32_t name, const char *iface, uint32_t version) {
  if (!strcmp(iface, wl_compositor_interface.name))
    compositor = wl_registry_bind(r, name, &wl_compositor_interface, 4);
  else if (!strcmp(iface, wl_shm_interface.name))
    shm = wl_registry_bind(r, name, &wl_shm_interface, 1);
  else if (!strcmp(iface, wp_viewporter_interface.name))
    viewporter = wl_registry_bind(r, name, &wp_viewporter_interface, 1);
  else if (!strcmp(iface, zwlr_layer_shell_v1_interface.name))
    layer_shell = wl_registry_bind(r, name, &zwlr_layer_shell_v1_interface, 1);
  else if (!strcmp(iface, wl_output_interface.name))
    wl_output_add_listener(wl_registry_bind(r, name, &wl_output_interface, 4), &output_listener, NULL);
}

static const struct wl_registry_listener registry_listener = {.global = global, .global_remove = noop};

static void configure(void *data, struct zwlr_layer_surface_v1 *ls, uint32_t serial, uint32_t w, uint32_t h) {
  zwlr_layer_surface_v1_ack_configure(ls, serial);
  wp_viewport_set_destination(viewport, w, h);
  wl_surface_attach(surface, buffer, 0, 0);
  wl_surface_commit(surface);
}

static void closed(void *data, struct zwlr_layer_surface_v1 *ls) { exit(0); }

static const struct zwlr_layer_surface_v1_listener layer_surface_listener = {.configure = configure, .closed = closed};

int main(int argc, char **argv) {
  output_name = argv[1];
  struct wl_display *display = wl_display_connect(NULL);
  wl_registry_add_listener(wl_display_get_registry(display), &registry_listener, NULL);
  wl_display_roundtrip(display); // globals
  wl_display_roundtrip(display); // output names
  if (!output) return 1;

  // a single zeroed XRGB pixel (true black), stretched to the output by the viewport
  int fd = memfd_create("blackout", 0);
  if (ftruncate(fd, 4)) return 1;
  struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, 4);
  buffer = wl_shm_pool_create_buffer(pool, 0, 1, 1, 4, WL_SHM_FORMAT_XRGB8888);

  surface = wl_compositor_create_surface(compositor);
  viewport = wp_viewporter_get_viewport(viewporter, surface);
  struct zwlr_layer_surface_v1 *ls = zwlr_layer_shell_v1_get_layer_surface(
      layer_shell, surface, output, ZWLR_LAYER_SHELL_V1_LAYER_OVERLAY, "blackout");
  zwlr_layer_surface_v1_set_anchor(ls, ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP | ZWLR_LAYER_SURFACE_V1_ANCHOR_BOTTOM |
                                           ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT | ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT);
  zwlr_layer_surface_v1_set_exclusive_zone(ls, -1); // ignore bars' exclusive zones
  zwlr_layer_surface_v1_add_listener(ls, &layer_surface_listener, NULL);
  wl_surface_commit(surface);

  while (wl_display_dispatch(display) != -1);
  return 0;
}
