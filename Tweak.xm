#import <UIKit/UIPushButton.h>
#import <UIKit/UIAlert.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIProgressHUD.h>

@interface PLPhotoScrollerViewController : UIViewController
-(UIImage *)currentUIImage;
-(id)currentImage;
-(id)pathForImageFile;
-(void)tweakWeekGrayScaleImageSaveCompleted;
-(id)currentImageView;
@end

@interface MLPhoto 
+(CGImageRef)createUnrotatedImageWithSize:(CGSize)size originalImage:(CGImageRef)image imageOrientation:(int)orientation;
@end

@interface UIThreePartButton : UIPushButton
@end

@interface UIActionSheet (additions)
-(id)buttonAtIndex:(int)index;
-(void)setDefaultButton:(id)button;
-(id)buttons;
-(int)buttonCount;
@end


static id mySheet=nil;
static id hud=nil;


%hook PLPhotoScrollerViewController

%new(v@:@@^v)-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *) error contextInfo:(void*)contextInfo{
	
	
	if (error && hud){
		[hud setText:@"Error converting image!"];
	}
	else if (!error && hud){
		[hud setText:@"Converted!"];
		[hud done];
	}
	if (hud)
	[hud performSelector:@selector(hide) withObject:nil afterDelay:1.2];	
}


-(void)actionSheet:(id)sheet clickedButtonAtIndex:(int)anIndex{
		%orig;
		if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
			hud=[ [[UIProgressHUD alloc] init] autorelease];
			[hud setText:@"Converting Image..."];
			[hud showInView:[[self currentImageView] window]];
		}
}


-(void)actionSheet:(id)sheet didDismissWithButtonIndex:(int)anIndex{

	if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
		
		NSString *imageFile=[[self currentImage] pathForImageFile];
		UIImage *image=[UIImage imageWithContentsOfFile:imageFile];
		UIImage *currentUIImage=[self currentUIImage];
		int orientation=[currentUIImage imageOrientation];
		CGImageRef rotatedImage=orientation !=0 ? (CGImageRef)[objc_getClass("MLPhoto") createUnrotatedImageWithSize:image.size  originalImage:[image CGImage] imageOrientation:orientation+1] : [image CGImage]; 
		CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
 		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
 		CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
 		CGContextDrawImage(context, imageRect,rotatedImage);
 		CGImageRef imageRef = CGBitmapContextCreateImage(context);
 		UIImage *newImage = [UIImage imageWithCGImage:imageRef ];
 		CGColorSpaceRelease(colorSpace);
		if (orientation !=0){
			CFRelease(rotatedImage);
		}
		CFRelease(imageRef);
		
		
 		UIImageWriteToSavedPhotosAlbum (newImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
		CGContextRelease(context);
		return;
	}
		
	%orig;
	
	
}


%end

%hook UIActionSheet

-(void)presentSheetInView:(id)view { 

	if ([[[[self buttons] objectAtIndex:0] title] isEqualToString:[[NSBundle bundleWithIdentifier:@"com.apple.PhotoLibrary"] localizedStringForKey:@"SEND_PHOTO_VIA_EMAIL_BUTTON" value:nil table:@"Main"]]) {
		mySheet=self;
		[self addButtonWithTitle:@"Convert to Grayscale"];
		UIThreePartButton *converButton= [[self buttons] lastObject];
		[[self buttons] removeObject:converButton];
		[[self buttons] insertObject:converButton atIndex:0];
		self.cancelButtonIndex = self.numberOfButtons-1;
	}
	
	%orig;
	
}
%end

