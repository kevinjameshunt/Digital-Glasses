#include <pebble.h>

#define KEY_BUTTON_RESET 2
#define KEY_BUTTON_UP   1
#define KEY_BUTTON_DOWN 0

#define NUM_MENU_SECTIONS 1
#define NUM_FIRST_MENU_ITEMS 6

typedef enum {
  MenuItemZoom,
  MenuItemBrightness,
  MenuItemContrast,
  MenuItemSaturation,
  MenuItemTorch,
  MenuItemReset,
  MenuItemCaptureImage
} MenuItem;

typedef struct {
  MenuItem menuItem;
} Context;

static MenuItem currentMenu;
static Window *window;
static Window *window_control;
static SimpleMenuLayer *menuLayer;
static TextLayer *text_layer_top;
static TextLayer *text_layer_select;
static TextLayer *text_layer_bottom;
static int torchState;

static SimpleMenuSection s_menu_sections[NUM_MENU_SECTIONS];
static SimpleMenuItem s_menu_items[NUM_FIRST_MENU_ITEMS];


static int menuIndexFromItem() {
	if (currentMenu == MenuItemZoom) {
		return 0;
	} else if (currentMenu == MenuItemBrightness) {
		return 1;
	} else if (currentMenu == MenuItemContrast) {
		return 2;
	} else if (currentMenu == MenuItemSaturation) {
		return 3;
	} else if (currentMenu == MenuItemTorch) {
		return 4;
	} else if (currentMenu == MenuItemReset) {
		return 5;
	} else if (currentMenu == MenuItemCaptureImage) {
		return 6;
	} else {
		return -1;
	}
}

static char* menuNameFromItem() {
	if (currentMenu == MenuItemZoom) {
		return "Zoom";
	} else if (currentMenu == MenuItemBrightness) {
		return "Brightness";
	} else if (currentMenu == MenuItemContrast) {
		return "Contrast";
	} else if (currentMenu == MenuItemSaturation) {
		return "Saturation";
	} else if (currentMenu == MenuItemTorch) {
		return "Light";
	} else if (currentMenu == MenuItemReset) {
		return "Reset";
	}  else if (currentMenu == MenuItemCaptureImage) {
		return "Preview";
	} else {
		return "";
	}
}

static void send(int key, int value) {
  // Create dictionary
  DictionaryIterator *iter;
  APP_LOG(APP_LOG_LEVEL_INFO, "Starting Send");
  // Prepare the outbox buffer for this message
  AppMessageResult result = app_message_outbox_begin(&iter);

  // Construct the message
  if(result == APP_MSG_OK) {
    // Add value to send
    dict_write_int(iter, key, &value, sizeof(int), true);

    // Send dictionary
    result = app_message_outbox_send();
    if(result != APP_MSG_OK) {
      APP_LOG(APP_LOG_LEVEL_ERROR, "Error sending the outbox: %d", (int)result);
    }
  } else {
    // The outbox cannot be used right now
    APP_LOG(APP_LOG_LEVEL_ERROR, "Error preparing the outbox: %d", (int)result);
  } 
  APP_LOG(APP_LOG_LEVEL_INFO, "Finishing Send");
}

static void outbox_sent_handler(DictionaryIterator *iter, void *context) {
  // Ready for next command
  text_layer_set_text(text_layer_select, menuNameFromItem());
}

static void outbox_failed_handler(DictionaryIterator *iter, AppMessageResult reason, void *context) {
  text_layer_set_text(text_layer_select, "Send failed!");
  APP_LOG(APP_LOG_LEVEL_ERROR, "Fail reason: %d", (int)reason);
}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
	// If we are moving backwards while previewing an image, assume we are discarding it.
	if (currentMenu == MenuItemCaptureImage) {
		send(MenuItemCaptureImage, KEY_BUTTON_DOWN);
	}
  
  	window_stack_pop(true);
}

static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  send(menuIndexFromItem(), KEY_BUTTON_UP);
  
  // If we are saving the image, should return to the curren view
	if (currentMenu == MenuItemReset || currentMenu == MenuItemCaptureImage) {
		window_stack_pop(true);
	}
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
	if (currentMenu != MenuItemReset) {
	  send(menuIndexFromItem(), KEY_BUTTON_DOWN);
	}
	
  	// If we are discarding the image, should return to the current view
	if (currentMenu == MenuItemReset || currentMenu == MenuItemCaptureImage ) {
		window_stack_pop(true);
	}
}

static void control_click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
  window_single_click_subscribe(BUTTON_ID_BACK, select_click_handler);
}

static void window_control_load(Window *window) {
	Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);
  
  text_layer_select = text_layer_create((GRect) { .origin = { 0, 62 }, .size = { bounds.size.w, 30 } });
  text_layer_set_text(text_layer_select, menuNameFromItem());
  text_layer_set_text_alignment(text_layer_select, GTextAlignmentCenter);
  text_layer_set_font(text_layer_select, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
  layer_add_child(window_layer, text_layer_get_layer(text_layer_select));
  
  text_layer_top = text_layer_create((GRect) { .origin = { 0, 0 }, .size = { bounds.size.w, 42 } });
  text_layer_set_font(text_layer_top, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
  if (currentMenu == MenuItemTorch) {
  	text_layer_set_text(text_layer_top, "ON");
  } else if (currentMenu == MenuItemReset) {
  	text_layer_set_text(text_layer_top, "YES");
  } else if (currentMenu == MenuItemCaptureImage) {
  	text_layer_set_text(text_layer_top, "SAVE");
  } else {
	text_layer_set_text(text_layer_top, "+");
	text_layer_set_font(text_layer_top, fonts_get_system_font(FONT_KEY_BITHAM_42_BOLD));
  }
  text_layer_set_text_alignment(text_layer_top, GTextAlignmentRight);
  layer_add_child(window_layer, text_layer_get_layer(text_layer_top));
  
  text_layer_bottom = text_layer_create((GRect) { .origin = { 0, 120 }, .size = { bounds.size.w, 42 } });
  text_layer_set_font(text_layer_bottom, fonts_get_system_font(FONT_KEY_GOTHIC_28_BOLD));
  if (currentMenu == MenuItemTorch) {
  	text_layer_set_text(text_layer_bottom, "OFF");
  } else if (currentMenu == MenuItemReset) {
  	text_layer_set_text(text_layer_bottom, "NO");
  } else if (currentMenu == MenuItemCaptureImage) {
  	text_layer_set_text(text_layer_bottom, "CANCEL");
  } else {
  	text_layer_set_text(text_layer_bottom, "-");
  	text_layer_set_font(text_layer_bottom, fonts_get_system_font(FONT_KEY_BITHAM_42_BOLD));
  }
  text_layer_set_text_alignment(text_layer_bottom, GTextAlignmentRight);
  layer_add_child(window_layer, text_layer_get_layer(text_layer_bottom));
}

static void window_control_unload(Window *window) {
  text_layer_destroy(text_layer_select);
  text_layer_destroy(text_layer_top);
  text_layer_destroy(text_layer_bottom);
}

static void menu_select_callback(int index, void *ctx) {
	// An action was selected, determine which one
	currentMenu = index;
	APP_LOG(APP_LOG_LEVEL_INFO, "Menu Selected");
	
	// Capture a picture while we load the menu
	if (currentMenu == MenuItemCaptureImage) {
		// Instruct the app that we are capturing the image, as opposed to saving or discarding it
	  	send(MenuItemCaptureImage, MenuItemCaptureImage);
	}
	
	window_control = window_create();
	window_set_click_config_provider(window_control, control_click_config_provider);
	window_set_window_handlers(window_control, (WindowHandlers) {
	  .load = window_control_load,
	  .unload = window_control_unload,
	});
	const bool animated = true;
	 window_stack_push(window_control, animated);
	APP_LOG(APP_LOG_LEVEL_INFO, "Menu Selected - Finishing method");
}

static void window_load(Window *window) {
	Layer *window_layer = window_get_root_layer(window);
	GRect bounds = layer_get_bounds(window_layer);
	
	int num_a_items = 0;
	
	s_menu_items[num_a_items++] = (SimpleMenuItem) {
    	.title = "Zoom",
    	.callback = menu_select_callback,
  	};
  
	s_menu_items[num_a_items++] = (SimpleMenuItem) {
    	.title = "Brightness",
    	.callback = menu_select_callback,
  	};
  	
  	s_menu_items[num_a_items++] = (SimpleMenuItem) {
    	.title = "Contrast",
    	.callback = menu_select_callback,
  	};
  	
  	s_menu_items[num_a_items++] = (SimpleMenuItem) {
    	.title = "Saturation",
    	.callback = menu_select_callback,
  	};
  	
  	s_menu_items[num_a_items++] = (SimpleMenuItem) {
    	.title = "Light",
    	.callback = menu_select_callback,
  	};
  	
  	s_menu_items[num_a_items++] = (SimpleMenuItem) {
    	.title = "Reset All",
    	.callback = menu_select_callback,
  	};
  	
//  	s_menu_items[num_a_items++] = (SimpleMenuItem) {
//    	.title = "Take Photo",
//    	.callback = menu_select_callback,
//  	};
  	
  	s_menu_sections[0] = (SimpleMenuSection) {
	    .num_items = NUM_FIRST_MENU_ITEMS,
	    .items = s_menu_items,
	};

  menuLayer = simple_menu_layer_create(bounds, window, s_menu_sections, NUM_MENU_SECTIONS, NULL);
  layer_add_child(window_layer, simple_menu_layer_get_layer(menuLayer));

}

static void window_unload(Window *window) {
  simple_menu_layer_destroy(menuLayer);
}

static void init(void) {
  window = window_create();
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);
  torchState = 0;
  
  // Open AppMessage and register callbacks
  app_message_register_outbox_sent(outbox_sent_handler);
  app_message_register_outbox_failed(outbox_failed_handler);
  app_message_open(app_message_inbox_size_maximum(), app_message_outbox_size_maximum());
}

static void deinit(void) {
  window_destroy(window);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
