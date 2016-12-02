//
//  MathController.h
//  Run Tracker
//
//  Created by Esma on 12/13/15.
//  Copyright © 2015 Esma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathController : NSObject

+ (NSString *)stringifyDistance:(float)meters usingLongFormat:(BOOL)longFormat inMetricUnits:(BOOL)isMetric;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat inMetricUnits:(BOOL)isMetric;
+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds usingLongFormat:(BOOL)longFormat inMetricUnits:(BOOL)isMetric;
+ (NSArray *)colorSegmentsForLocations:(NSArray *)locations;

@end
