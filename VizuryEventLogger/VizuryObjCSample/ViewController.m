//
//  ViewController.m
//  VizuryObjCSample
//
//  Created by Chowdhury Md Rajib  Sarwar on 15/9/20.
//  Copyright © 2020 Chowdhury Md Rajib  Sarwar. All rights reserved.
//

#import "ViewController.h"
#import <VizuryEventLogger/VizuryEventLogger.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", [VizuryEventLogger getFCMToken]);
    
    NSLog(@"%@", [VizuryEventLogger getAdvertisingId]);
    
}

- (IBAction)normalEvent:(id)sender {
    NSDictionary *attributeDictionary  =   [[NSDictionary alloc] initWithObjectsAndKeys:
                                            @"AKSJDASNBD",@"productid",
                                            @"789", @"productPrice",
                                            @"Shirt",@"category",
                                            nil];
    
    [VizuryEventLogger logEvent:@"product page" WithAttributes:attributeDictionary];
}

// you can send the attributes as JSONArray or JSONObject also
- (IBAction)JSONEvent:(UIButton *)sender {
    
    // sending a JSONObject
    NSDictionary *productDetail = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"62112",@"product_id",
                                   @"1",@"quantity",
                                   @"50", @"price",
                                   nil];
    
    NSData *productjsonData = [NSJSONSerialization dataWithJSONObject:productDetail options:0 error:nil];
    NSString *productjsonStr = [[NSString alloc] initWithData:productjsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *productjsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           productjsonStr,@"viz_data",
                                           nil];
    [VizuryEventLogger logEvent:@"productDetails" WithAttributes:productjsonDictionary];
    
    // sending a JSON Array of Objects
    NSMutableArray *products = [[NSMutableArray alloc] init];
    NSDictionary *productDetail1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"62112",@"product_id",
                                    @"1",@"quantity",
                                    @"50", @"price",
                                    nil];
    
    NSDictionary *productDetail2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"123123",@"product_id",
                                    @"1",@"quantity",
                                    @"50", @"price",
                                    nil];
    
    [products addObject:productDetail1];
    [products addObject:productDetail2];
    
    NSData *wishListjsonData = [NSJSONSerialization dataWithJSONObject:products options:0 error:nil];
    NSString *wishListjsonStr = [[NSString alloc] initWithData:wishListjsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *wishListjsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                            wishListjsonStr,@"viz_data",
                                            nil];
    
    [VizuryEventLogger logEvent:@"wishlist" WithAttributes:wishListjsonDictionary];
}

@end
