//
//  CPImageView
//  Created by Can Poyrazoğlu on 22.11.13.
//  Open source. Download it, modify it, use it!
//  Yes, even for commercial projects!

#import <UIKit/UIKit.h>
typedef void (^CPImageHandler)(UIImage *loadedImage);
typedef UIImage *(^CPImageProcessingFunction)(UIImage *loadedImage);

@interface CPImageView : UIImageView
-(void)setImageFromURL:(id)url;

-(id)initWithImageURL:(id)imageURL;

-(void)setImageFromURL:(id)url clearPreviousImageWhileLoading:(BOOL)clear;
+(void)clearCache;
+(UIImage*)storedImageForURL:(id)url;
+(void)storeImage:(UIImage*)img forURL:(id)url;
+(void)logEventDetails;

@property(copy) CPImageHandler imageLoadedHandler;
@property NSURL *url;
@property(copy) CPImageProcessingFunction imageProcessingFunction;
@end
