//
//  NewRunViewController.h
//  Run Tracker
//
//  Created by Esma on 12/13/15.
//  Copyright © 2015 Esma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface NewRunViewController : UIViewController <ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
