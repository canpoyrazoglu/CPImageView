//
//  CPImageView
//  Created by Can Poyrazoğlu on 22.11.13.
//  Open source. Download it, modify it, use it!
//  Yes, even for commercial projects!

#import <UIKit/UIKit.h>
typedef void (^CPImageHandler)(UIImage *loadedImage);
typedef UIImage *(^CPImageProcessingFunction)(UIImage *loadedImage);

@interface CPImageView : UIImageView
-(void)setImageFromURLString:(NSString*)urlString;
-(void)setImageFromURL:(NSURL*)url;

-(id)initWithImageURL:(NSURL *)imageURL;
-(id)initWithImageURLString:(NSString *)imageURLString;

-(void)setImageFromURL:(NSURL*)url clearPreviousImageWhileLoading:(BOOL)clear;
-(void)setImageFromURLString:(NSString*)urlString clearPreviousImageWhileLoading:(BOOL)clear;
+(void)clearCache;
+(UIImage*)persistentCachedImageForURL:(NSString*)url;
+(void)persistentlyCacheImage:(UIImage*)img forURL:(NSURL*)url;
+(void)logEventDetails;

@property(copy) CPImageHandler imageLoadedHandler;
@property NSURL *url;
@property(copy) CPImageProcessingFunction imageProcessingFunction;
@end
