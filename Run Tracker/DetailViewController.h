//
//  DetailViewController.h
//  Run Tracker
//
//  Created by Esma on 12/13/15.
//  Copyright © 2015 Esma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

