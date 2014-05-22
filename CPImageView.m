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

+(UIImage*)persistentCachedImageForURL:(NSString*)url{
    NSString *path = [url stringByTrimmingCharactersInSet:[CPImageView nonAlphaNumericalCharacterSet]];
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    path = [path stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    path = [NSString stringWithFormat:@"CPImageViewCache_%@", path];
    NSString *fullPath = [[CPImageView documentsDirectory] stringByAppendingPathComponent:path];
    return [UIImage imageWithContentsOfFile:fullPath];
}

+(void)persistentlyCacheImage:(UIImage*)img forURL:(NSURL*)url{
    NSString *path = url.absoluteString;
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    path = [path stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    path = [NSString stringWithFormat:@"CPImageViewCache_%@", path];
    path = [path stringByTrimmingCharactersInSet:[CPImageView nonAlphaNumericalCharacterSet]];
    NSString *fullPath = [[CPImageView documentsDirectory] stringByAppendingPathComponent:path];
    [UIImageJPEGRepresentation(img, 0.9) writeToFile:fullPath atomically:NO];
}

-(id)initWithImageURL:(NSURL *)imageURL{
    self = [super init];
    if(self){
        [self setImageFromURL:imageURL];
    }
    return self;
}

-(id)initWithImageURLString:(NSString *)imageURLString{
    self = [super init];
    if(self){
        [self setImageFromURLString:imageURLString];
    }
    return self;
}

-(void)setImageFromURLString:(NSString*)urlString{
    while ([urlString hasPrefix:@" "]) {
        urlString = [urlString substringFromIndex:1];
    }
    [self setImageFromURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

-(void)setImageFromURLString:(NSString*)urlString clearPreviousImageWhileLoading:(BOOL)clear{
    while ([urlString hasPrefix:@" "]) {
        urlString = [urlString substringFromIndex:1];
    }
    [self setImageFromURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] clearPreviousImageWhileLoading:clear];
}

-(void)setImageFromURL:(NSURL*)url{
    [self setImageFromURL:url clearPreviousImageWhileLoading:YES];
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
    unsigned int items = CPImageViewCache.count;
    if(items){
        [CPImageViewCache removeAllObjects];
        NSLog(@"[CPImageView] Cleared %d items from cache due to memory pressure", items);
    }
}

-(void)setImageFromURL:(NSURL*)url clearPreviousImageWhileLoading:(BOOL)clear{
    self.url = url;
    if(!CPImageViewCache){
        CPImageViewCache = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name: UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    NSString *thisURL = url.absoluteString;
    @synchronized(self){
        loadingURL = thisURL;
    }
    UIImage *img = [CPImageViewCache objectForKey:url];
    self.contentMode = UIViewContentModeScaleAspectFill;
    if(!img){ //not found on memory cache
        img = [CPImageView persistentCachedImageForURL:url.absoluteString];
        if(!img){ //not found on persistent cache too. we need to download the image
            if(clear){
                [self setImage:nil];
            }
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0L), ^{
                UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                if(downloadedImage){
                    if(CPImageViewShouldLogDetailedEvents){
                        NSLog(@"[CPImageView] Loaded image from URL %@", url.absoluteString);
                    }
                    [CPImageView persistentlyCacheImage:downloadedImage forURL:url];
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
                    NSLog(@"[CPImageView] Unable to load %@", url.absoluteString);
                }
            });
        }else{ //loaded from persistent cache (file system)
            if(CPImageViewShouldLogDetailedEvents){
                NSLog(@"[CPImageView] Loaded storage-cached image %@", url.absoluteString);
            }
            [self setImage:img];
            if(self.imageLoadedHandler){
                self.imageLoadedHandler(img);
            }
        }
    }else{ //loaded from memory cache (RAM)
        if(CPImageViewShouldLogDetailedEvents){
            NSLog(@"[CPImageView] Loaded memory-cached image %@", url.absoluteString);
        }
        [self setImage:img];
        if(self.imageLoadedHandler){
            self.imageLoadedHandler(img);
        }
    }
}


@end
