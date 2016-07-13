//
//  BLCPersistanceObject.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 13/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCProfilePictureImageView;

typedef void(^profilePictureIsStoredBlock)(BLCProfilePictureImageView *loadedImageView);
typedef void(^nothingFoundBlock)(void);

@interface BLCPersistanceObject : NSObject

+ (NSString *) pathForFilename:(NSString *) filename;

+ (void)loadProfilePictureDataFromDisk:(profilePictureIsStoredBlock)isStoredBlock nothingFound:(nothingFoundBlock)nothingFound;

@end
