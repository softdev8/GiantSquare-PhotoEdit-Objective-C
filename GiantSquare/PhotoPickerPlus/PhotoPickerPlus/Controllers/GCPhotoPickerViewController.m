//
//  PhotoPickerViewController.m
//  GCAPIv2TestApp
//
//  Created by Chute Corporation on 7/24/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCPhotoPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoPickerCell.h"
#import "GCAssetsCollectionViewController.h"
#import "GCAccountMediaViewController.h"
#import "GCAlbumViewController.h"
#import "NSDictionary+ALAsset.h"
#import "GCServiceAccount.h"
#import "GCAccount.h"
#import "GCConfiguration.h"

#import "GCOAuth2Client.h"
#import "GCLoginView.h"
#import "MBBProgressHUD.h"


@interface GCPhotoPickerViewController ()

@property (nonatomic) BOOL isItDevice;

@end

@implementation GCPhotoPickerViewController

@synthesize delegate, isMultipleSelectionEnabled = _isMultipleSelectionEnabled;
@synthesize oauth2Client;
@synthesize isItDevice;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.navigationItem.title = @"Photo Picker";
    
    [self setCancelButton];
    [self.tableView registerClass:[PhotoPickerCell class] forCellReuseIdentifier:@"GroupCell"];
    
    //go directly to service
    if (_isFacebookService) {
        [self goToService:0];
    }else if (_isInstagramService){
        [self goToService:3];
    }
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationController.navigationBar.translucent = YES;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Device";
    else
        return @"Services";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 3;
    else
        return [[[GCConfiguration configuration] services] count];
}

- (PhotoPickerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";

    PhotoPickerCell *cell = [[PhotoPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if(indexPath.section == 0){
        if(indexPath.row == 0)
        {
            cell.titleLabel.text = @"Take Photo";
            [cell.imageView setImage:[UIImage imageNamed:@"camera.png"]];
        }
        else if (indexPath.row == 1)
        {
            cell.titleLabel.text = @"Choose Photo";
            [cell.imageView setImage:[UIImage imageNamed:@"defaultThumb.png"]];
        }
        else if (indexPath.row == 2)
        {
            cell.titleLabel.text = @"Latest Photo";
            [cell.imageView setImage:[UIImage imageNamed:@"defaultThumb.png"]];
        }
    }
    else if(indexPath.section == 1)
    {
        NSString *serviceName = [[[GCConfiguration configuration] services] objectAtIndex:indexPath.row];
        GCService service = [GCOAuth2Client serviceForString:serviceName];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.png", serviceName];
        UIImage *temp = [UIImage imageNamed:imageName];
        [cell.imageView setImage:temp];
        
        NSString *cellTitle = [[serviceName capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];

        for (GCAccount *account in [[GCConfiguration configuration] accounts]) {
            if ([account.type isEqualToString:[GCOAuth2Client loginMethodForService:service]]) {
                if (account.name) {
                    cellTitle = account.name;
                }
                else if (account.username){
                    cellTitle = account.username;
                }
            }
        }
        [cell.titleLabel setText:cellTitle];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0)
        {

            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:nil];
        }
        else if (indexPath.row == 1)
        {
           [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            self.isItDevice = YES;
            
            GCAlbumViewController *daVC = [[GCAlbumViewController alloc] init];
            [daVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            [daVC setSuccessBlock:[self successBlock]];
            [daVC setCancelBlock:[self cancelBlock]];
            [daVC setIsItDevice:self.isItDevice];
            
            [self.navigationController pushViewController:daVC animated:YES];
        }
        else if (indexPath.row == 2)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self getLatestPhoto];
        }
    }
    else if(indexPath.section == 1)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self goToService:indexPath.row];
    }
}

- (void)goToService:(NSInteger)pServiceType{
    self.isItDevice = NO;
    NSLog(@"pServiceType  - %i", pServiceType);
    
    NSString *serviceName = [[[GCConfiguration configuration] services] objectAtIndex:pServiceType];
    
    for (GCAccount *account in [[GCConfiguration configuration] accounts]) {
        if ([account.type isEqualToString:serviceName]) {
            
            GCAccountMediaViewController *amVC = [[GCAccountMediaViewController alloc] init];
            [amVC setIsItDevice:self.isItDevice];
            [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            [amVC setAccountID:account.id];
            [amVC setServiceName:serviceName];
            [amVC setSuccessBlock:[self successBlock]];
            [amVC setCancelBlock:[self cancelBlock]];
            
            [self.navigationController pushViewController:amVC animated:YES];
            [self.tableView reloadData];
            return;
        }
    }
    
    GCService service = [GCOAuth2Client serviceForString:serviceName];
    [GCLoginView showOAuth2Client:self.oauth2Client service:service success:^{
        NSLog(@"Logged in!");
        [GCServiceAccount getProfileInfoWithSuccess:^(GCResponseStatus *responseStatus, NSArray *accounts) {
#warning Doesn't work with merges, this part must be changed in future!
            GCAccount *account;
            for (GCAccount *acc in accounts) {
                NSLog(@"%@ compare: %@", [GCOAuth2Client loginMethodForService:service], acc.type);
                if ([[GCOAuth2Client loginMethodForService:service] isEqualToString:acc.type])
                    account = acc;
                
                [[GCConfiguration configuration] addAccount:acc];
            }
            if (!account)
                return;
            
            NSLog(@"AccountID:%@",[account id]);
            //                [[GCConfiguration configuration] addAccount:account];
            
            GCAccountMediaViewController *amVC = [[GCAccountMediaViewController alloc] init];
            [amVC setIsItDevice:self.isItDevice];
            [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            [amVC setAccountID:account.id];
            [amVC setServiceName:serviceName];
            [amVC setSuccessBlock:[self successBlock]];
            [amVC setCancelBlock:[self cancelBlock]];
            
            [self.tableView reloadData];
            [self.navigationController pushViewController:amVC animated:YES];
            
        } failure:^(NSError *error) {
            NSLog(@"No Account Data");
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failure - %@", [error localizedDescription]);
    }];

}

#pragma mark - Custom Methods

- (void)getLatestPhoto
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate all the photos and videos group by using ALAssetsGroupAll.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
        if (group != nil && [group numberOfAssets] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have any photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset)
                [self successBlock]([NSDictionary infoFromALAsset:alAsset]);
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups to be enumerated.");
    }];

}

- (void)setCancelButton
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)cancel
{
    if([self.delegate respondsToSelector:@selector(photoImagePickerControllerDidCancel:)])
    {
        [self.delegate photoImagePickerControllerDidCancel:(PhotoPickerViewController *)self.navigationController];
    }
}

#pragma mark - UIImagePicker Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancelBlock]();
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self successBlock](info);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info
{
    [self successBlock](info);
}

#pragma mark - Callbacks

- (void (^)(id selectedItems))successBlock
{
    void (^successBlock)(id selectedItems) = ^(id selectedItems){
        if ([selectedItems isKindOfClass:[NSDictionary class]] && [self.delegate respondsToSelector:@selector(photoImagePickerController:didFinishPickingMediaWithInfo:)]) {
            [self.delegate photoImagePickerController:(PhotoPickerViewController *)self.navigationController didFinishPickingMediaWithInfo:selectedItems];
        }
        else if ([selectedItems isKindOfClass:[NSArray class]] && [self.delegate respondsToSelector:@selector(photoImagePickerController:didFinishPickingArrayOfMediaWithInfo:)]) {
            [self.delegate photoImagePickerController:(PhotoPickerViewController *)self.navigationController didFinishPickingArrayOfMediaWithInfo:selectedItems];
        }
    };
    return successBlock;
}

- (void (^)(void))cancelBlock
{
    void (^cancelBlock)(void) = ^{
        if([self.delegate respondsToSelector:@selector(photoImagePickerControllerDidCancel:)])
        {
            [self.delegate photoImagePickerControllerDidCancel:(PhotoPickerViewController *)self.navigationController];
        }
    };
    return cancelBlock;
}

#pragma mark - Setters

- (void)setIsMultipleSelectionEnabled:(BOOL)isMultipleSelectionEnabled
{
    if(_isMultipleSelectionEnabled != isMultipleSelectionEnabled)
        _isMultipleSelectionEnabled = isMultipleSelectionEnabled;
}


@end
