//
//  MainViewController.m
//  Flickr-Modanisa
//
//  Created by Selay Soysal on 26/04/2017.
//  Copyright © 2017 Selay Soysal. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    [_blurView setHidden:YES];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
   
    _flickrs = [NSMutableArray array];
    
    [defaults setInteger:1 forKey:@"fav"];
    [defaults synchronize];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self searchByTag:1 tag:@"moda"];
}
// rest api call
-(void)searchByTag:(NSInteger)page tag:(NSString*)tag{
    
    NSString *flickrAPIKey = @"134d8331bbd9dfc00024ed60092bf5c6";
        
    NSString *urlString =
    [NSString stringWithFormat:
     @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&per_page=50&page=%ld&format=json&nojsoncallback=1",
     flickrAPIKey,tag,(long)page];
    
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getPhotos:data];
        });
    }];
    [dataTask resume];
}

// json parsing
- (void)getPhotos:(NSData *)data
{
    NSError *error = nil;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray *photos = [[json objectForKey:@"photos"] objectForKey:@"photo"];
    
    _totalPages  = [[[json objectForKey:@"photos"] objectForKey:@"pages"] integerValue];
    _totalItems  = [[[json objectForKey:@"photos"] objectForKey:@"total"] integerValue];
    _currentPage = [[[json objectForKey:@"photos"] objectForKey:@"page"] integerValue];
    
        for (NSDictionary *photo in photos)
        {
            //flickr object
            Flickr *flickr = [[Flickr alloc] init];

            NSString *smallPhotoURL = [NSString stringWithFormat:@"http://farm%@.static.flickr.com", [photo objectForKey:@"farm"]];
            smallPhotoURL = [NSString stringWithFormat:@"%@/%@/%@_%@_q.jpg", smallPhotoURL, [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            flickr.photoSmallImageData = smallPhotoURL;
            flickr.photoId = [photo objectForKey:@"id"];
            NSString *largePhotoURL = [NSString stringWithFormat:@"http://farm%@.static.flickr.com", [photo objectForKey:@"farm"]];
            largePhotoURL = [NSString stringWithFormat:@"%@/%@/%@_%@_c.jpg", largePhotoURL, [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
            flickr.photoURLsLargeImage = largePhotoURL;
            
            [self.flickrs addObject:flickr];
        }
    [_collectionView reloadData];
    
}

// when user presses long on a collection view cell, will see the large photo.
-(IBAction)longPressGestureRecognized:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    // getting the location of cell and indexpath
    CGPoint location = [longPress locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];

    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
            // when state began
        case UIGestureRecognizerStateBegan: {
            
            if (indexPath) {
                
                sourceIndexPath = indexPath;
                [_blurView setHidden:NO];
                [_searchView setHidden:YES];
                
                Flickr *flickr = [_flickrs objectAtIndex:indexPath.row];
                NSString *imageUrl = flickr.photoURLsLargeImage;
                NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
                _imageView.image = [UIImage imageWithData:imageData];
            }
            break;
        }
            // when state changes
        case UIGestureRecognizerStateChanged: {
            [_blurView setHidden:YES];
            break;
        }
        default: {
            // default
            [_blurView setHidden:YES];
        break;
        }
    }
}

-(IBAction)searchClicked:(id)sender{
    [_flickrs removeAllObjects];
    [self searchByTag:1 tag:_searchBar.text];
    [_blurView setHidden:YES];
}
-(IBAction)searchTabClicked:(id)sender{
    [_blurView setHidden:NO];
    [_imageView setHidden:YES];
    [_searchView setHidden:NO];
}
-(IBAction)homeClicked:(id)sender{
    [_flickrs removeAllObjects];
    [self searchByTag:1 tag:@"moda"];
    [_blurView setHidden:YES];
}
//fav button Clicked
- (IBAction)favClicked:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FavsViewController *favVC = [storyboard instantiateViewControllerWithIdentifier:@"FavsViewController"];
    [self.navigationController pushViewController:favVC animated:YES];
}


// cell configuration

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_currentPage == _totalPages
        || _totalItems == _flickrs.count) {
        return _flickrs.count;
    }
    return _flickrs.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FlickrCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[FlickrCell alloc] init];
    }
    if(_flickrs.count>indexPath.row){
        Flickr *flickr = [_flickrs objectAtIndex:indexPath.row];
        NSString *imageUrl = flickr.photoSmallImageData;
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
        cell.cellImageView.image = [UIImage imageWithData:imageData];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==_flickrs.count-1){
        // increase current page
        [self searchByTag: ++_currentPage tag: _tag];
    }

}
// excatly 3 images per row
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = screenWidth / 3.02; //Replace the divisor with the column count requirement. Make sure to have it in float.
    CGSize size = CGSizeMake(cellWidth, cellWidth);
    return size;
}
// when user choose one cell, it will expanded on a new page
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    // moving datas to the other ViewController
    detailVC.flickrs = [[NSMutableArray alloc]init];
    [detailVC.flickrs addObjectsFromArray: _flickrs];
    detailVC.rowIndex = indexPath.row;
    [defaults setInteger:1 forKey:@"fav"];
    [defaults synchronize];
    [self.navigationController pushViewController:detailVC animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
