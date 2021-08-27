#include <gtk/gtk.h>
#include <vlc/vlc.h>
#include <flutter_linux/flutter_linux.h>
#include "wrapper.h"
#include "libvlc_gtkglarea.h"

struct AppData
{
  GtkWidget *stack;
  GtkWidget *overlay;
  FlView *view;
  libvlc_media_player_t *media_player;
};

struct AppData *appdata_new()
{
  return (struct AppData *)malloc(sizeof(struct AppData));
}

void on_back(GtkWidget *widget, gpointer *user_data)
{
  struct AppData *data = (struct AppData *)user_data;

  libvlc_media_player_stop(data->media_player);
  data->media_player = NULL;

  gtk_stack_set_visible_child(GTK_STACK(data->stack), GTK_WIDGET(data->view));
  gtk_container_remove(GTK_CONTAINER(data->stack), data->overlay);
  data->overlay = NULL;
}

static void method_call_cb(
    FlMethodChannel *channel,
    FlMethodCall *method_call,
    gpointer user_data)
{
  struct AppData *data = (struct AppData *)user_data;

  if (strcmp(fl_method_call_get_name(method_call), "play") == 0)
  {
    FlValue *args = fl_method_call_get_args(method_call);
    FlValue *value = fl_value_lookup_string(args, "uri");
    const char *uri = fl_value_get_string(value);

    // overlay
    data->overlay = gtk_overlay_new();
    gtk_widget_show(GTK_WIDGET(data->overlay));
    gtk_stack_add_named(
        GTK_STACK(data->stack), GTK_WIDGET(data->overlay), "vlc");
    gtk_stack_set_visible_child(
        GTK_STACK(data->stack), GTK_WIDGET(data->overlay));

    // back button
    GtkWidget *button = gtk_button_new();
    g_signal_connect(button, "clicked", G_CALLBACK(on_back), data);
    gtk_button_set_label(GTK_BUTTON(button), "Back");
    gtk_widget_show(GTK_WIDGET(button));
    gtk_overlay_add_overlay(GTK_OVERLAY(data->overlay), GTK_WIDGET(button));
    gtk_widget_set_valign(GTK_WIDGET(button), GTK_ALIGN_END);
    gtk_widget_set_halign(GTK_WIDGET(button), GTK_ALIGN_START);

    // player_widget
    GtkWidget *player_widget = gtk_gl_area_new();

    // media_player
    libvlc_instance_t *vlc_inst = libvlc_new(0, NULL);
    data->media_player = libvlc_media_player_new(vlc_inst);
    libvlc_media_t *media = libvlc_media_new_location(vlc_inst, uri);
    libvlc_media_player_set_media(data->media_player, media);
    libvlc_media_player_set_gtkglarea(
        data->media_player, GTK_GL_AREA(player_widget));
    libvlc_media_player_play(data->media_player);
    libvlc_media_release(media);

    // append player_widget
    gtk_widget_show(GTK_WIDGET(player_widget));
    gtk_container_add(GTK_CONTAINER(data->overlay), GTK_WIDGET(player_widget));

    fl_method_call_respond_success(method_call, NULL, NULL);
  }
  else
  {
    fl_method_call_respond_not_implemented(method_call, NULL);
  }
}

void wrapper_setup(GtkContainer *container, FlView *view)
{
  // data
  struct AppData *data = appdata_new();

  // stack
  data->stack = gtk_stack_new();
  gtk_widget_show(GTK_WIDGET(data->stack));
  gtk_container_add(container, GTK_WIDGET(data->stack));

  // flutter view
  data->view = view;
  gtk_stack_add_named(
      GTK_STACK(data->stack), GTK_WIDGET(data->view), "flutter");

  // setup method channel handler
  FlEngine *engine = fl_view_get_engine(data->view);
  FlBinaryMessenger *messenger = fl_engine_get_binary_messenger(engine);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  FlMethodChannel *channel =
      fl_method_channel_new(
          messenger,
          "com.github.birros.flutter_vlc_demo/video",
          FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel,
      method_call_cb,
      data,
      NULL);
}