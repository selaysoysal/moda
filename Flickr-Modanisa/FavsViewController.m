//
//  FavsViewController.m
//  Flickr-Modanisa
//
//  Created by Selay Soysal on 28/04/2017.
//  Copyright © 2017 Selay Soysal. All rights reserved.
//

#import "FavsViewController.h"

@interface FavsViewController ()

@end

@implementation FavsViewController
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
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _favs = [[NSMutableArray alloc]init];
    _selectedFav= [[NSMutableArray alloc] init];
     defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Favs"];
    _favs = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [_collectionView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _favs.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FavCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"favCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[FavCell alloc] init];
    }
    if(_favs.count>indexPath.row){
        NSManagedObject *url = [_favs objectAtIndex:indexPath.row];
        NSString* link = [url valueForKey:@"link"];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: link]];
        cell.favImage.image = [UIImage imageWithData:imageData];
        //[cell.backgroundColor: [UIColor blueColor] CGColor]];
    }
    return cell;
}
// when user choose one cell, it will expanded on a new page
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    // moving datas to the other ViewController
    
    detailVC.rowIndex = indexPath.row;
    [defaults setInteger:2 forKey:@"fav"];
    [defaults synchronize];
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
