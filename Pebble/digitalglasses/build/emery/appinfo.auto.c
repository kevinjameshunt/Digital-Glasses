#include "pebble_process_info.h"
#include "src/resource_ids.auto.h"

const PebbleProcessInfo __pbl_app_info __attribute__ ((section (".pbl_header"))) = {
  .header = "PBLAPP",
  .struct_version = { PROCESS_INFO_CURRENT_STRUCT_VERSION_MAJOR, PROCESS_INFO_CURRENT_STRUCT_VERSION_MINOR },
  .sdk_version = { PROCESS_INFO_CURRENT_SDK_VERSION_MAJOR, PROCESS_INFO_CURRENT_SDK_VERSION_MINOR },
  .process_version = { 1, 0 },
  .load_size = 0xb6b6,
  .offset = 0xb6b6b6b6,
  .crc = 0xb6b6b6b6,
  .name = "DigitalGlasses",
  .company = "Prophet Studios",
  .icon_resource_id = RESOURCE_ID_MENU_ICON,
  .sym_table_addr = 0xA7A7A7A7,
  .flags = PROCESS_INFO_PLATFORM_EMERY,
  .num_reloc_entries = 0xdeadcafe,
  .uuid = { 0x69, 0xA1, 0xA8, 0x21, 0x67, 0x88, 0x4D, 0xC0, 0xAD, 0x2F, 0x4B, 0xE4, 0x7B, 0x98, 0x20, 0xCF },
  .virtual_size = 0xb6b6
};
