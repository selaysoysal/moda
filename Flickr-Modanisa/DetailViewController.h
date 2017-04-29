//
//  DetailViewController.h
//  Flickr-Modanisa
//
//  Created by Selay Soysal on 27/04/2017.
//  Copyright © 2017 Selay Soysal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "AppDelegate.h"
#import "PhotoInfo.h"
#import "Flickr.h"


@interface DetailViewController : UIViewController<UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (strong) NSMutableArray *favs;
@property(strong) NSMutableArray *flickrs; // URL to larger image
@property(strong) NSMutableArray *photoInfo;
@property NSInteger rowIndex;



@end
