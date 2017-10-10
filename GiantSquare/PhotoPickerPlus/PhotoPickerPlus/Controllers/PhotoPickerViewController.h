//
//  PhotoPickerViewController.h
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 8/10/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoPickerViewController;

/**
 The `PhotoPickerViewControllerDelegate` defines the methods that are used when picking an asset. They actually return selected assets or cancel the action.
*/
@protocol PhotoPickerViewControllerDelegate <NSObject>

@optional
/**
 Called when the user had finished picking and had selected one asset.
 */
- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
/**
 Called when the user had finished picking and had selected multiple assets, which are returned in an array.
 */
- (void)photoImagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info;
/**
 Called when the user canceled the picking.
 */
- (void)photoImagePickerControllerDidCancel:(PhotoPickerViewController *)picker;
@end

@interface PhotoPickerViewController : UINavigationController

/**
 The PhotoPickerViewController and UINavigationController delegate object.
 
 @see PhotoPickerViewControllerDelegate
 @see UINavigationControllerDelegate
*/
@property (assign, nonatomic) id<PhotoPickerViewControllerDelegate, UINavigationControllerDelegate>delegate;

/**
 BOOL value with which is determined if the user can select multiple assets (YES) or not (NO).
 */
@property (assign, nonatomic) BOOL isMultipleSelectionEnabled;

- (id)initWithService:(NSInteger)pService;

@end