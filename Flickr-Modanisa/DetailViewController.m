//
//  DetailViewController.m
//  Flickr-Modanisa
//
//  Created by Selay Soysal on 27/04/2017.
//  Copyright © 2017 Selay Soysal. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
{
    NSManagedObjectContext* managedObjectContext;
    NSUserDefaults *defaults;
}
- (NSManagedObjectContext *)managedObjectContext {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return appDelegate.persistentContainer.viewContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    _photoInfo = [[NSMutableArray alloc]init];
    _favs = [[NSMutableArray alloc]init];
    defaults = [NSUserDefaults standardUserDefaults];
    
    // gesture adding on view for previous and next posts
    UISwipeGestureRecognizer *nextpost = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(nextPost:)];
    [nextpost setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    UISwipeGestureRecognizer *prepost = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(previousPost:)];
    [prepost setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:nextpost];
    [self.view addGestureRecognizer:prepost];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Favs"];
    _favs = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self showDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//coredata entegration

-(void) storeFavs:(NSString*)link{

    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newFav = [NSEntityDescription insertNewObjectForEntityForName:@"Favs" inManagedObjectContext:context];
    
    [newFav setValue:link forKey:@"link"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}


//share buttonClicked
- (IBAction)shareClicked:(id)sender {
    NSString *textToShare = @"Look at this photo!";
    Flickr *flickr = [_flickrs objectAtIndex:_rowIndex];
    NSString *imageUrl = flickr.photoURLsLargeImage;
    NSURL *myWebsite = [NSURL URLWithString:imageUrl];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypeMessage,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];

}
-(IBAction)homeClicked:(id)sender{

    [self.navigationController popViewControllerAnimated:YES];
}
//like button Clicked
- (IBAction)likeClicked:(id)sender {
    if ([defaults integerForKey:@"fav"]==1){
        Flickr *flickr = [_flickrs objectAtIndex:_rowIndex];
        NSString *imageUrl = flickr.photoURLsLargeImage;
        [self storeFavs:imageUrl];
        [_likeButton setImage:[UIImage imageNamed:@"heart-4"] forState:UIControlStateNormal];
    }
    else{
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:[_favs objectAtIndex:_rowIndex]];
         [_likeButton setImage:[UIImage imageNamed:@"heart-2"] forState:UIControlStateNormal];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
    }
}

//image and page show
-(void)showDetails{
    if ([defaults integerForKey:@"fav"]==1){
        [_likeButton setImage:[UIImage imageNamed:@"heart-2"] forState:UIControlStateNormal];
        Flickr *flickr = [_flickrs objectAtIndex:_rowIndex];
        NSString *imageUrl = flickr.photoURLsLargeImage;
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
        [self getPhotoInfo:flickr.photoId];
        _imageView.image = [UIImage imageWithData:imageData];
    }
    else{
        [_likeButton setImage:[UIImage imageNamed:@"heart-4"] forState:UIControlStateNormal];
        NSManagedObject *url = [_favs objectAtIndex:_rowIndex];
        NSString* link = [url valueForKey:@"link"];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: link]];
        _imageView.image = [UIImage imageWithData:imageData];
        _textView.text = @"";
    }
        

    
}
// getting info from webservice
-(void)getPhotoInfo:(NSString*)photoid{
    NSString *flickrAPIKey = @"134d8331bbd9dfc00024ed60092bf5c6";
    NSString *urlString =
    [NSString stringWithFormat:
     @"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1",
     flickrAPIKey, photoid];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self photoInfo:data];
        });
    }];
    [dataTask resume];
}
//parsing photo info, tags, comments, authorname etc...

- (void)photoInfo:(NSData *)data
{
    NSError *error = nil;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *tags = [[[json objectForKey:@"photo"]objectForKey:@"tags"]objectForKey:@"tag"];
    for (NSDictionary *tag in tags)
    {
        PhotoInfo *photo = [[PhotoInfo alloc] init];
        
        NSString *authorname = [tag objectForKey:@"authorname"];
        NSString *raw = [tag objectForKey:@"raw"];
        
        photo.authorname = authorname;
        photo.tag = raw;
        [_photoInfo addObject:photo];
    }
    NSString *tag = @"";
    NSString *name;
    //////// duzelt
    for (int i=0;i< _photoInfo.count;i++){
        PhotoInfo *photo =[_photoInfo objectAtIndex:i];
        name = photo.authorname;
        tag = [ NSString stringWithFormat: @"%@ #%@",tag,photo.tag];
    }
    NSString *yourString = [NSString stringWithFormat:@"%@ %@",name,tag];
    NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:yourString];
    NSRange boldRange = [yourString rangeOfString:name];
    [yourAttributedString addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:boldRange];
    [_textView setAttributedText: yourAttributedString];
    
}
//gesture for previous post
-(void)previousPost:(UISwipeGestureRecognizer *)gestureRecognizer{
    if( _rowIndex > 0){
        _rowIndex = _rowIndex-1;
        [self showDetails];
    }
}
//gesture for next post
-(void)nextPost:(UISwipeGestureRecognizer *)gestureRecognizer{
        if ([defaults integerForKey:@"fav"]==1){
            if( _rowIndex < _flickrs.count){
                _rowIndex = _rowIndex+1;
                [self showDetails];
            }
    }
    else{
        if( _rowIndex < _favs.count){
            _rowIndex = _rowIndex+1;
            [self showDetails];
        }
    }
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
