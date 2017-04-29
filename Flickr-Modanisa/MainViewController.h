//
//  MainViewController.h
//  Flickr-Modanisa
//
//  Created by Selay Soysal on 26/04/2017.
//  Copyright © 2017 Selay Soysal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "FavsViewController.h"
#import "FlickrCell.h"
#import "Flickr.h"
@interface MainViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *searchBarButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong) NSMutableArray *flickrs;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalPages;
@property (nonatomic, assign) NSInteger totalItems;
@property (strong) NSString *tag;
@end
