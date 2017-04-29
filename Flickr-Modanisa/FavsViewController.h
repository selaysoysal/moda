//
//  FavsViewController.h
//  Flickr-Modanisa
//
//  Created by Selay Soysal on 28/04/2017.
//  Copyright © 2017 Selay Soysal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "FavCell.h"

@interface FavsViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong) NSMutableArray *favs;
@property BOOL selectEnabled;
@property (strong) NSMutableArray *selectedFav;
@end
