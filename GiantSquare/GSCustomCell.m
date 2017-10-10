//
//  GSCustomCell.m
//  GiantSquare
//
//  Created by Lion on 3/18/14.
//  Copyright (c) 2014 Vakoms. All rights reserved.
//

#import "GSCustomCell.h"

@implementation GSCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if(selected)
    {
        
        
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
           [self.m_cellBack setBackgroundColor:[UIColor orangeColor]];
        } completion:^(BOOL finished) {
             [self.m_cellBack setBackgroundColor:[UIColor clearColor]];
            
        }];
    }
    else
    {
        [self.m_cellBack setBackgroundColor:[UIColor clearColor]];
    }
    
}

@end
