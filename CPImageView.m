//
//  CPImageView
//  Created by Can Poyrazoğlu on 22.11.13.
//

#import "CPImageView.h"

@implementation CPImageView{
    NSString *loadingURL;
}

static NSString *documentsDir;
static NSCharacterSet *nonAlphaNumericalSet;
static BOOL CPImageViewShouldLogDetailedEvents;

+(NSString *)documentsDirectory {
    if(!documentsDir){
        documentsDir = ((NSURL*)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                        inDomains:NSUserDomainMask] lastObject]).path;
    }
    return documentsDir;
}

+(void)logEventDetails{
    CPImageViewShouldLogDetailedEvents = YES;
}

+(NSCharacterSet*)nonAlphaNumericalCharacterSet{
    if(!nonAlphaNumericalSet){
        nonAlphaNumericalSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    }
    return nonAlphaNumericalSet;
}

+(UIImage*)storedImageForURL:(id)url{
    //accept both NSString and NSURL, convert URL to string if required
    if([url isKindOfClass:[NSURL class]]){
        url = [url absoluteString];
    }
    NSString *path = [url stringByTrimmingCharactersInSet:[CPImageView nonAlphaNumericalCharacterSet]];
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    path = [path stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    path = [NSString stringWithFormat:@"CPImageViewCache_%@", path];
    NSString *fullPath = [[CPImageView documentsDirectory] stringByAppendingPathComponent:path];
    return [UIImage imageWithContentsOfFile:fullPath];
}

+(void)storeImage:(UIImage*)img forURL:(id)url{
    //accept both NSString and NSURL, convert string to URL if required
    if([url isKindOfClass:[NSString class]]){
        url = [NSURL URLWithString:url];
    }
    NSString *path = [url absoluteString];
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    path = [path stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    path = [NSString stringWithFormat:@"CPImageViewCache_%@", path];
    path = [path stringByTrimmingCharactersInSet:[CPImageView nonAlphaNumericalCharacterSet]];
    NSString *fullPath = [[CPImageView documentsDirectory] stringByAppendingPathComponent:path];
    [UIImageJPEGRepresentation(img, 0.9) writeToFile:fullPath atomically:NO];
}

-(id)initWithImageURL:(id)imageURLString{
    self = [super init];
    if(self){
        [self setImageFromURL:imageURLString];
    }
    return self;
}

-(void)setImageFromURL:(NSString*)urlString{
    [self setImageFromURL:urlString clearPreviousImageWhileLoading:NO];
}

static NSMutableDictionary *CPImageViewCache;

+(void)clearCache{
    [CPImageViewCache removeAllObjects];
}

-(void)setImage:(UIImage *)image{
    self.backgroundColor = [UIColor clearColor];
    BOOL shouldChange = (image != self.image);
    if(shouldChange){
        if(self.imageProcessingFunction && image){
            image = self.imageProcessingFunction(image);
        }
        [super setImage:image];
        if(self.imageLoadedHandler){
            self.imageLoadedHandler(image);
        }
    }
}

-(void)didReceiveMemoryWarning:(NSNotification*)notif{
    NSUInteger items = CPImageViewCache.count;
    if(items){
        [CPImageViewCache removeAllObjects];
        NSLog(@"[CPImageView] Cleared %d items from cache due to memory pressure", items);
    }
}

-(void)setImageFromURL:(id)url clearPreviousImageWhileLoading:(BOOL)clear{
    if(!url){
        [self setImage:nil];
        return;
    }
    if([url isKindOfClass:[NSString class]]){
        while ([url hasPrefix:@" "]) {
            url = [url substringFromIndex:1];
        }
        url = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    self.url = url;
   
    if(!CPImageViewCache){
        CPImageViewCache = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name: UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    NSString *thisURL = [url absoluteString];
    @synchronized(self){
        loadingURL = thisURL;
    }
    UIImage *img = [CPImageViewCache objectForKey:url];
    self.contentMode = UIViewContentModeScaleAspectFill;
    if(!img){ //not found on memory cache
        img = [CPImageView storedImageForURL:[url absoluteString]];
        if(!img){ //not found on persistent cache too. we need to download the image
            if(clear){
                [self setImage:nil];
            }
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0L), ^{
                UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                if(downloadedImage){
                    if(CPImageViewShouldLogDetailedEvents){
                        NSLog(@"[CPImageView] Loaded image from URL %@", [url absoluteString]);
                    }
                    [CPImageView storeImage:downloadedImage forURL:url];
                    BOOL updateImageView = NO;
                    @synchronized(CPImageViewCache){
                        [CPImageViewCache setObject:downloadedImage forKey:url];
                    }
                    @synchronized(self){
                        if([thisURL isEqualToString:loadingURL]){
                            updateImageView = YES;
                        }
                    }
                    if(updateImageView){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setImage:downloadedImage];
                            if(self.imageLoadedHandler){
                                self.imageLoadedHandler(downloadedImage);
                            }
                        });
                    }
                }else{
                    NSLog(@"[CPImageView] Unable to load %@", [url absoluteString]);
                }
            });
        }else{ //loaded from persistent cache (file system)
            if(CPImageViewShouldLogDetailedEvents){
                NSLog(@"[CPImageView] Loaded storage-cached image %@", [url absoluteString]);
            }
            [self setImage:img];
            if(self.imageLoadedHandler){
                self.imageLoadedHandler(img);
            }
        }
    }else{ //loaded from memory cache (RAM)
        if(CPImageViewShouldLogDetailedEvents){
            NSLog(@"[CPImageView] Loaded memory-cached image %@", [url absoluteString]);
        }
        [self setImage:img];
        if(self.imageLoadedHandler){
            self.imageLoadedHandler(img);
        }
    }
}


@end
