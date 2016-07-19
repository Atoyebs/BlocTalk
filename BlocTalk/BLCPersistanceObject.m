//
//  BLCPersistanceObject.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 13/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCPersistanceObject.h"
#import "BLCProfilePictureImageView.h"

@implementation BLCPersistanceObject


+ (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}



+(void)loadProfilePictureDataFromDisk:(profilePictureIsStoredBlock)isStoredBlock nothingFound:(nothingFoundBlock)nothingFound {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //get the fullPath of the same file you saved/wrote to earlier
        NSString *fullPath = [BLCPersistanceObject pathForFilename:NSStringFromSelector(@selector(profilePicImage))];
        
        //unarchive the file into the SAME DATA/OBJECT TYPE YOU SAVED/WROTE it with
        BLCProfilePictureImageView *loadedImageView = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        //go back to the main queue as you've now finished the heavy lifting
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (loadedImageView) {
                isStoredBlock(loadedImageView);
            }
            else {
                nothingFound();
            }
        
        });
    });
    
}


@end
