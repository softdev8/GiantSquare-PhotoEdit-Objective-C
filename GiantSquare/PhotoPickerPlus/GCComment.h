//
//  GCComent.h
//  Chute-SDK
//
//  Created by Aleksandar Trpeski on 4/22/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import <Foundation/Foundation.h>

/* SAMPLE
{
    "id": 591,
    "links": {
        "self": {
        "href": "http://api.getchute.com/v2/comments/591",
        "title": "Comment Details"
    }
    },
    "created_at": "2012-12-04T13:58:53Z",
    "updated_at": "2012-12-04T13:58:53Z",
    "comment_text": "Some random comment",
    "name": "Darko",
    "email": "random@someemail.com"
}
 */

@class GCLinks;

@interface GCComment : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) GCLinks *links;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;

@end
