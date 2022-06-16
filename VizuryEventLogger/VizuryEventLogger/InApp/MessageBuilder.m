//
//  MessageBuilder.m
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 28/5/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import "MessageBuilder.h"
#import "Popup.h"
#import "ImageTableCell.h"
#import "SingleButtonTableCell.h"
#import "KeyConstants.h"
#import <UIKit/UIKit.h>
#import "DoubleButtonTableCell.h"
#import "TextTableCell.h"

@implementation MessageBuilder

Popup* popup;
NSMutableArray* cells;

NSArray* viewConfigs;
NSArray* buttonConfigs;
NSDictionary* textConfigs;
NSString* layout;

NSString* text;
UIImage* image;
float imageWidth = 0;
float imageHeight = 0;
float textHeight = 0;

NSString* click_url;

long popupHeight = 0;
int numberOfRows = 0;
BOOL isImageAvailable = false;

float MINIMUM_WIDTH = 150;

static MessageBuilder *singletonObject = nil;

+(id) getInstance {
    if(!singletonObject) {
        singletonObject = [[MessageBuilder alloc] init];
    }
    return singletonObject;
}

- (id)init {
    if (!singletonObject) {
        singletonObject = [super init];
    }
    return singletonObject;
}

-(void) showMessage: (NSString*) bannerId {
    
    buttonConfigs = [[NSMutableArray alloc] init];
    NSString* key = [NSString stringWithFormat:@"%@_%@", IN_APP_CONFIG, bannerId];
    NSDictionary* config = [UserDefaultsManager getUserDefaultDictionaryForKey:key];
    
    if (config  == NULL) {
        return;
    }
    
    [self prepareContent:config ofBanner:bannerId];
    
    [self sendImpressionReceipt:[config objectForKey:GCM_IMPRESSION_URL]];
}

-(void) sendImpressionReceipt: (NSString*) urlString {
    NSString* deviceId = [DeviceIdentificationManager advertisingID];
    NSString *url = [urlString stringByReplacingOccurrencesOfString:@"{deviceId}" withString:deviceId];
    [self sendDataToServer:url];
}

-(void) prepareContent: (NSDictionary*) config ofBanner: (NSString*) bannerId {
    
    cells = [[NSMutableArray alloc] init];
    
    click_url = [config objectForKey:GCM_CLICK_URL];
    viewConfigs = [config valueForKey:IN_APP_MESSAGE_VIEW];
    popupHeight = 0;
    numberOfRows = 0;
    
    isImageAvailable = false;
    for (NSDictionary* view in viewConfigs) {
        NSString* type = [view objectForKey:IN_APP_MESSAGE_VIEW_TYPE];
        if ([type caseInsensitiveCompare:IN_APP_MESSAGE_IMAGE_VIEW] == NSOrderedSame) {
            [cells addObject:IN_APP_MESSAGE_IMAGE_VIEW];
            isImageAvailable = true;
            numberOfRows = numberOfRows + 1;
        } else if ([type caseInsensitiveCompare:IN_APP_MESSAGE_TEXT_VIEW] == NSOrderedSame) {
            [cells addObject:IN_APP_MESSAGE_TEXT_VIEW];
            text = [view objectForKey:IN_APP_MESSAGE_TEXT_VIEW];
            textConfigs = view;
            numberOfRows = numberOfRows + 1;
        }
    }
    
    if (isImageAvailable) {
        NSString* keyImage = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_BANNER_IMAGE, bannerId];
        NSString* keyImageWidth = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_IMAGE_VIEW_WIDTH, bannerId];
        NSString* keyImageHeight = [NSString stringWithFormat:@"%@_%@", IN_APP_MESSAGE_IMAGE_VIEW_HEIGHT, bannerId];
       
        NSString* imageString = [UserDefaultsManager getUserDefaultStringForKey:keyImage];
        if (imageString == nil) {
            [VizLog logMessage:@"Image failed to download"];
            return;
        }
        NSData* imageData = [[NSData alloc] initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        image = [UIImage imageWithData:imageData];
        imageWidth = [[UserDefaultsManager getUserDefaultValueForKey:keyImageWidth] floatValue];
        imageHeight = [[UserDefaultsManager getUserDefaultValueForKey:keyImageHeight] floatValue];
        if (keyImageHeight == 0) {
            return;
        }
    }
    
    buttonConfigs = [config valueForKey:IN_APP_MESSAGE_BUTTON];
    layout = [config objectForKey: IN_APP_MESSAGE_BUTTON_ORIENTATION];
    
    if (buttonConfigs.count > 0) {
        if ([layout caseInsensitiveCompare:IN_APP_MESSAGE_BUTTON_ORIENTATION_VERTICAL] == NSOrderedSame) {
            numberOfRows = numberOfRows + (int) buttonConfigs.count;
            popupHeight = popupHeight + (50 * buttonConfigs.count);
        } else {
            numberOfRows = numberOfRows + 1;
            popupHeight = popupHeight + 50;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showPopup];
    });
}

-(CGSize)getLabelHeight:(CGFloat)width {

    int fontSize = [[textConfigs objectForKey:IN_APP_MESSAGE_VIEW_FONT_SIZE] intValue];
    UIFont* font;
    
    if ([[textConfigs objectForKey:IN_APP_MESSAGE_VIEW_FONT_STYLE] caseInsensitiveCompare:IN_APP_MESSAGE_VIEW_FONT_STYLE_BOLD] == NSOrderedSame) {
        font = [UIFont boldSystemFontOfSize: fontSize];
    } else if ([[textConfigs objectForKey:IN_APP_MESSAGE_VIEW_FONT_STYLE] caseInsensitiveCompare:IN_APP_MESSAGE_VIEW_FONT_STYLE_ITALIC] == NSOrderedSame) {
        font = [UIFont italicSystemFontOfSize: fontSize];
    } else {
        font = [UIFont boldSystemFontOfSize: fontSize];
    }
    
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size;

    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:font}
                                                  context:context].size;

    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));

    return size;
}

-(void) showPopup {
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    UITableView* tableView = [[UITableView alloc] init];
    if (isImageAvailable) {
        float ratio =  imageHeight / imageWidth;
        float frameWidth = mainScreen.size.width - (mainScreen.size.width/10);
        frameWidth = frameWidth > imageWidth ? imageWidth : frameWidth;
        frameWidth = frameWidth < MINIMUM_WIDTH ? MINIMUM_WIDTH : frameWidth;
        imageHeight = frameWidth * ratio;
        popupHeight = popupHeight + imageHeight;
        
        if (text.length > 0) {
            CGSize size = [self getLabelHeight:frameWidth];
            [VizLog logMessage:[NSString stringWithFormat:@"This is label Height: %f, Width: %f", size.height, size.width]];
            textHeight = size.height + 16;
            popupHeight = popupHeight + textHeight;
        }
        
        float mainscreenHeight = mainScreen.size.height - (mainScreen.size.height/10);
        if (popupHeight > mainscreenHeight) {
            popupHeight = mainscreenHeight;
        }
        
        tableView.frame = CGRectMake(0.0, 0.0, frameWidth, popupHeight);
    } else {
        
        CGFloat popupWidth = mainScreen.size.width - (mainScreen.size.width/10);
        if (text.length > 0) {
            CGSize size = [self getLabelHeight:popupWidth];
            [VizLog logMessage:[NSString stringWithFormat:@"This is label Height: %f, Width: %f", size.height, size.width]];
            textHeight = size.height + 16;
            popupHeight = popupHeight + textHeight;
        }
                
        tableView.frame = CGRectMake(0.0, 0.0, popupWidth, popupHeight);
    }
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = (id<UITableViewDelegate>)self;
    tableView.dataSource = (id<UITableViewDataSource>)self;
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.allowsSelection = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = false;
    tableView.showsHorizontalScrollIndicator = false;
    tableView.scrollEnabled = true;
        
    popup = [Popup popupWithContentView: tableView];
    [popup show];
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
   
    if(indexPath.row < viewConfigs.count) {
        NSString* cellType = cells[indexPath.row];
        if ([cellType caseInsensitiveCompare:IN_APP_MESSAGE_IMAGE_VIEW] == NSOrderedSame) {
            static NSString *CellIdentifier = @"imageCellID";
            UINib* nib = [UINib nibWithNibName:@"ImageTableCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            ImageTableCell *cell = (ImageTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.imageView.image = image;
            cell.button.tag = indexPath.row;
            [cell.button addTarget:self action:@selector(imageClicked:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        } else if ([cellType caseInsensitiveCompare:IN_APP_MESSAGE_TEXT_VIEW] == NSOrderedSame) {
            static NSString* CellIdentifier = @"textCellID";
            UINib* nib = [UINib nibWithNibName:@"TextTableCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            TextTableCell *cell = (TextTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            [self configureLabel:cell.lblText withConfig:viewConfigs[indexPath.row]];
            return cell;
        } else {
            return [[UITableViewCell alloc] init];
        }
    } else {
        if ([layout caseInsensitiveCompare:IN_APP_MESSAGE_BUTTON_ORIENTATION_VERTICAL] == NSOrderedSame) {
            static NSString *CellIdentifier = @"singleButtonCellID";
            UINib* nib = [UINib nibWithNibName:@"SingleButtonTableCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            SingleButtonTableCell *cell = (SingleButtonTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSDictionary* buttonConfig = buttonConfigs[indexPath.row - viewConfigs.count];
            [cell.button setTag:indexPath.row - viewConfigs.count];
            [self configureButton:cell.button withConfig:buttonConfig];
            [cell.button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        } else {
            static NSString *CellIdentifier = @"doubleButtonCellID";
            UINib* nib = [UINib nibWithNibName:@"DoubleButtonTableCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            DoubleButtonTableCell *cell = (DoubleButtonTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
           
            [self configureButton:cell.btnLeft withConfig:buttonConfigs[0]];
            [self configureButton:cell.btnRight withConfig:buttonConfigs[1]];
            
            [cell.btnLeft setTag: 0];
            [cell.btnLeft addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];

            [cell.btnRight setTag: 1];
            [cell.btnRight addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }
}

-(void)imageClicked:(UIButton*)sender {
    NSString* urlString = [viewConfigs[sender.tag] objectForKey:IN_APP_MESSAGE_VIEW_DEEP_LINK];
    if (![urlString isEqualToString:@""]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString] options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
        }
        [self sendClickReceipt];
    }
}

- (void)btnClicked:(UIButton*)sender {
    NSString* urlString = [buttonConfigs[sender.tag] objectForKey:IN_APP_MESSAGE_VIEW_DEEP_LINK];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString] options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
    }
    [self sendClickReceipt];
}

-(void) sendClickReceipt {
    NSString* deviceId = [DeviceIdentificationManager advertisingID];
    NSString *url = [click_url stringByReplacingOccurrencesOfString:@"{deviceId}" withString:deviceId];
    [self sendDataToServer:url];
}

-(void) configureButton: (UIButton*) button withConfig: (NSDictionary*) config {
    [button setBackgroundColor:[self colorWithHexString: [config objectForKey: IN_APP_MESSAGE_VIEW_BG_COLOR]]];
    
    [button setTitle: [config objectForKey:IN_APP_MESSAGE_BUTTON_LABEL] forState:UIControlStateNormal];
    [button setTitleColor:[self colorWithHexString: [config objectForKey:IN_APP_MESSAGE_VIEW_FONT_COLOR]] forState:UIControlStateNormal];
    
    int fontSize = [[config objectForKey:IN_APP_MESSAGE_VIEW_FONT_SIZE] intValue];
    if ([[config objectForKey:IN_APP_MESSAGE_VIEW_FONT_STYLE] caseInsensitiveCompare:IN_APP_MESSAGE_VIEW_FONT_STYLE_BOLD] == NSOrderedSame) {
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize: fontSize]];
    } else if ([[config objectForKey:IN_APP_MESSAGE_VIEW_FONT_STYLE] caseInsensitiveCompare:IN_APP_MESSAGE_VIEW_FONT_STYLE_ITALIC] == NSOrderedSame) {
        [button.titleLabel setFont:[UIFont italicSystemFontOfSize: fontSize]];
    } else {
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize: fontSize]];
    }
    [button.layer setCornerRadius:[[config objectForKey:IN_APP_MESSAGE_VIEW_CORNER_RADIUS] intValue]];
    [button.layer setBorderColor:[[self colorWithHexString:[config objectForKey:IN_APP_MESSAGE_VIEW_BORDER_COLOR]] CGColor]];
    [button.layer setBorderWidth:1];
}

-(void) configureLabel: (UILabel*) label withConfig: (NSDictionary*) config {
    [label setBackgroundColor: [UIColor whiteColor]];
    int radius = [[config objectForKey:IN_APP_MESSAGE_VIEW_CORNER_RADIUS] intValue];

    [label setText: [config objectForKey:IN_APP_MESSAGE_TEXT_VIEW_CONTENT]];
    [label setTextColor:[self colorWithHexString: [config objectForKey:IN_APP_MESSAGE_VIEW_FONT_COLOR]]];
    
    int fontSize = [[config objectForKey:IN_APP_MESSAGE_VIEW_FONT_SIZE] intValue];
    if ([[config objectForKey:IN_APP_MESSAGE_VIEW_FONT_STYLE] caseInsensitiveCompare:IN_APP_MESSAGE_VIEW_FONT_STYLE_BOLD] == NSOrderedSame) {
        [label setFont:[UIFont boldSystemFontOfSize: fontSize]];
    } else if ([[config objectForKey:IN_APP_MESSAGE_VIEW_FONT_STYLE] caseInsensitiveCompare:IN_APP_MESSAGE_VIEW_FONT_STYLE_ITALIC] == NSOrderedSame) {
        [label setFont:[UIFont italicSystemFontOfSize: fontSize]];
    } else {
        [label setFont:[UIFont boldSystemFontOfSize: fontSize]];
    }
    
    label.layer.cornerRadius = radius;
    label.layer.masksToBounds = YES;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numberOfRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < viewConfigs.count) {
        NSString* type = cells[indexPath.row];
        if ([type caseInsensitiveCompare:IN_APP_MESSAGE_IMAGE_VIEW] == NSOrderedSame) {
            return imageHeight;
        } else {
            return textHeight;
        }
    }
    return 50;
}

-(UIColor*)colorWithHexString:(NSString*)hex {
    NSString *hexString = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

    if ([cString length] != 6) return  [UIColor grayColor];

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)sendDataToServer:(NSString *)urlString {
    
    if(urlString.length == 0) {
        [VizLog logMessage:@"sendDataToServer. empty url passed"];
        return;
    }
    
    [VizLog log:@"sending data with url " message:urlString];
      
    @try {
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString: urlString]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            [VizLog logMessage:[NSString stringWithFormat:@"Response code of the data sent %ld", (long)[httpResponse statusCode]]];
            NSInteger statusCode = [httpResponse statusCode];
            
            if(statusCode != 200 ) {
                [VizLog log:@"Error response body " message: httpResponse.description];
                return;
            }
        }] resume];
    } @catch (NSException *exception) {
        [VizLog log:@"IOExcetion while sending the data to server " message:exception.description];
        return;
    }
}

@end
