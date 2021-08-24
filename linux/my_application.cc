#include "my_application.h"
#include <flutter_linux/flutter_linux.h>
#include <gdk/gdkx.h>
#include <vlc/vlc.h>
#include "flutter/generated_plugin_registrant.h"
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

struct _MyApplication
{
  GtkApplication parent_instance;
  char **dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication *application)
{
  MyApplication *self = MY_APPLICATION(application);
  GtkWindow *window =
      GTK_WINDOW(
          gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = FALSE;

  GdkScreen *screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen))
  {
    const gchar *wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0)
    {
      use_header_bar = FALSE;
    }
  }

  if (use_header_bar)
  {
    GtkHeaderBar *header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "flutter_vlc_demo");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  }
  else
  {
    gtk_window_set_title(window, "flutter_vlc_demo");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  // data
  struct AppData *data = appdata_new();

  // stack
  data->stack = gtk_stack_new();
  gtk_widget_show(GTK_WIDGET(data->stack));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(data->stack));

  // flutter view
  data->view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(data->view));
  gtk_stack_add_named(GTK_STACK(data->stack), GTK_WIDGET(data->view), "flutter");

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

  fl_register_plugins(FL_PLUGIN_REGISTRY(data->view));

  gtk_widget_grab_focus(GTK_WIDGET(data->view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication *application, gchar ***arguments, int *exit_status)
{
  MyApplication *self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error))
  {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject *object)
{
  MyApplication *self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass *klass)
{
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication *self) {}

MyApplication *my_application_new()
{
  return MY_APPLICATION(
      g_object_new(
          my_application_get_type(),
          "application-id", APPLICATION_ID,
          "flags", G_APPLICATION_NON_UNIQUE,
          nullptr));
}
