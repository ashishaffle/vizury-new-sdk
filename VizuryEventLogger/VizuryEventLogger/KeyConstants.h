//
//  KeyConstants.h
//  VizuryEventLogger
//
//  Created by Akshat Singhal on 06/01/15.
//  Copyright (c) 2015 vizury. All rights reserved.
//

#ifndef VizuryEventLogger_KeyConstants_h
#define VizuryEventLogger_KeyConstants_h


#define VIZ_PACKAGE_ID  @"PACKAGE_ID"
#define SERVER_URL		@"SERVER_URL"
#define INITIALISED		@"INITIALISED"

#define EVENT_NAME_KEY              @"vizard_event_name"
#define VIZ_KEY_PACKAGE_ID			@"package_id"
#define VIZ_KEY_ADVERTISING_ID		@"adv_id"
#define VIZ_KEY_LIMIT_TRACKING		@"is_lat"
#define VIZ_KEY_API_VERSION			@"api_ver"
#define VIZ_KEY_APP_NAME			@"app_name"
#define VIZ_KEY_APP_VERSION			@"app_ver"
#define VIZ_KEY_APP_INSTALL_DATE	@"i_dt"
#define VIZ_KEY_APP_UPDATE_DATE		@"u_dt"
#define VIZ_KEY_GCM_TOKEN           @"gcmid"
#define VIZ_BANNER_ID_KEY           @"bannerid"
#define VIZ_ZONR_ID_KEY             @"zoneid"
#define VIZ_NOTIFICATION_ID         @"notificationid"
#define VIZ_PUSH_FROM               @"push_from"
#define VIZ_PUSH_SOURCE_VIZURY      @"vizury"
#define VIZ_IMPRESSION_RECEIPT      @"impression"
#define VIZ_CLICK_RECEIPT           @"click"
#define VIZ_PUSH_ENABLED            @"pushenabled"

#define VIZ_CLICK_URL               @"https://www.vizury.com/vizserver//www/delivery/ck.php"
#define VIZ_IMPR_URL                @"https://www.vizury.com/campaign/showad.php"

#define IS_NOTIFICATION_ALERT_ENABLED  @"isNotificationEnabled"
#define MACRO(string) [NSStringWithFormat:@"{{%@}}",string]
//
//#define MACRO(string) [NSString stringWithFormat:@"{{%@}}",string]

#define GCM_VIZURY_PUSH_TYPE                        @"viz_push_type"
#define GCM_VIZURY_SILENT_PUSH                      @"silent"
#define GCM_IMPRESSION_URL                          @"impr"
#define GCM_CLICK_URL                               @"click"


#define IN_APP_MESSAGE_TRIGGER                      @"trigger"
#define IN_APP_MESSAGE_TRIGGER_START_DATE           @"start_date"
#define IN_APP_MESSAGE_TRIGGER_END_DATE             @"end_date"
#define IN_APP_MESSAGE_DATETIME_FORMAT              @"yyyy-MM-dd-HH:mm:ss ZZ"
#define IN_APP_MESSAGE_TRIGGER_INTERVAL             @"interval"
#define IN_APP_MESSAGE_TRIGGER_CAP                  @"cap"

#define IN_APP_MESSAGE_VIEW                         @"view"
#define IN_APP_MESSAGE_VIEW_TYPE                    @"type"
#define IN_APP_MESSAGE_VIEW_BG_COLOR                @"bg_color"
#define IN_APP_MESSAGE_VIEW_BG_IMAGE                @"bg_image"
#define IN_APP_MESSAGE_VIEW_PADDING                 @"padding"
#define IN_APP_MESSAGE_VIEW_DEEP_LINK               @"dl"
#define IN_APP_MESSAGE_VIEW_BORDER_COLOR            @"border_color"
#define IN_APP_MESSAGE_VIEW_BORDER_WIDTH            @"border_width"
#define IN_APP_MESSAGE_VIEW_CORNER_RADIUS           @"corner_radius"
#define IN_APP_MESSAGE_VIEW_FONT_COLOR              @"font_color"
#define IN_APP_MESSAGE_VIEW_FONT_STYLE              @"font_style"
#define IN_APP_MESSAGE_VIEW_FONT_STYLE_BOLD         @"bold"
#define IN_APP_MESSAGE_VIEW_FONT_STYLE_ITALIC       @"italic"
#define IN_APP_MESSAGE_VIEW_FONT_STYLE_BOLD_ITALIC  @"bold-italic"
#define IN_APP_MESSAGE_VIEW_FONT_SIZE               @"font_size"


#define IN_APP_MESSAGE_IMAGE_VIEW                   @"image"
#define IN_APP_MESSAGE_BANNER_IMAGE                 @"banner_image"
#define IN_APP_MESSAGE_IMAGE_VIEW_WIDTH             @"image_width"
#define IN_APP_MESSAGE_IMAGE_VIEW_HEIGHT            @"image_height"
#define IN_APP_MESSAGE_IMAGE_VIEW_URL               @"url"

#define IN_APP_MESSAGE_TEXT_VIEW                    @"text"
#define IN_APP_MESSAGE_TEXT_VIEW_CONTENT            @"text"

#define IN_APP_MESSAGE_BUTTON                       @"button"
#define IN_APP_MESSAGE_BUTTON_LABEL                 @"label"

#define IN_APP_MESSAGE_BUTTON_ORIENTATION           @"button_layout"
#define IN_APP_MESSAGE_BUTTON_ORIENTATION_VERTICAL  @"vertical"


#define IN_APP_MESSAGE_CLOSE_BUTTON                 @"cb"

#define ACTIVE_CONFIG_ID                            @"activeBanner"

#define IN_APP_BANNER_ID                            @"BannerId"

#define IN_APP_CONFIG_IS_ACTIVE                     @"isActive"

#define IN_APP_VIEW_TYPE_BODY                       @"body"
#define IN_APP_VIEW_TYPE_BUTTON                     @"button"
#define IN_APP_REVERSE_MAPPING_BANNER_IDS           @"reverseMapping"
#define GCM_VIZURY_INAPP_TYPE                       @"GCM_VIZURY_INAPP_PUSH"
#define IN_APP_CONFIG                               @"IN_APP_CONFIG"

#define IN_APP_ACTIVE_BANNERS                       @"activeBanners"
#define IN_APP_CONFIG_IMPRESSION                    @"impressionDetails"

#endif
