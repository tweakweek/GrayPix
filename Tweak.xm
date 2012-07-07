#import <UIKit/UIPushButton.h>
#import <UIKit/UIAlert.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIProgressHUD.h>
#import <substrate.h>


@interface MLPhoto 
+(CGImageRef)createUnrotatedImageWithSize:(CGSize)size originalImage:(CGImageRef)image imageOrientation:(int)orientation;
-(id)pathForOriginalFile;
+(BOOL)instancesRespondToSelector:(SEL)selector;
@end

@interface PLAlbumsController : UIViewController
-(UIImage *)currentUIImage;
-(MLPhoto *)currentImage;
-(void)tweakWeekGrayScaleImageSaveCompleted;
-(id)currentImageView;
@end

@interface PLPhotoScrollerViewController : UIViewController
-(UIImage *)currentUIImage;
-(MLPhoto *)currentImage;
-(void)tweakWeekGrayScaleImageSaveCompleted;
-(id)currentImageView;
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

static UIImage * grayscaleImage(UIImage *image,int orientation){

	BOOL IOS5= [NSFileManager instancesRespondToSelector:@selector(URLForUbiquityContainerIdentifier:)];
	CGImageRef rotatedImage=orientation !=0 ? (IOS5 ?  (CGImageRef)[objc_getClass("PLManagedAsset")  newUnrotatedImageWithSize:image.size  originalImage:[image CGImage] imageOrientation: image.imageOrientation+1] : (CGImageRef)[objc_getClass("MLPhoto") createUnrotatedImageWithSize:image.size  originalImage:[image CGImage] imageOrientation:orientation+1] ): [image CGImage]; 

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
	CGContextRelease(context);
	return newImage;
}


%group IOS5
%hook PLPhonePhotoScrollerViewController

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


-(void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(int)anIndex{

		if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
			hud=[[UIProgressHUD alloc] init] ;
			[hud setText:@"Converting Image..."];
			[hud showInView:[[self view] window]];
		}
		
		if (anIndex==sheet.numberOfButtons-1){
			anIndex=sheet.cancelButtonIndex-1;
		}
		%orig;
}


-(void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(int)anIndex{

	if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
		
		NSString *imageFile=[[[self currentTile] photo] pathForOriginalFile];
		UIImage *image=[UIImage imageWithContentsOfFile:imageFile];

		int orientation=(int)[[[self currentTile] photo] orientationValue];
		
 		UIImageWriteToSavedPhotosAlbum (grayscaleImage(image,orientation), self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
		
		return;
	}
		
	if (anIndex==sheet.numberOfButtons-1){
		anIndex=sheet.cancelButtonIndex-1;
	}
		
	%orig;
		
}
%end
%end


%group newerVersions
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


-(void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(int)anIndex{

		if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
			hud=[[UIProgressHUD alloc] init] ;
			[hud setText:@"Converting Image..."];
			[hud showInView:[[self currentImageView] window]];
		}
		
		if (anIndex==sheet.numberOfButtons-1){
			anIndex=sheet.cancelButtonIndex-1;
		}
		%orig;
}


-(void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(int)anIndex{

	if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
		
		NSString *imageFile=[[self currentImage] pathForOriginalFile];
		UIImage *image=[UIImage imageWithContentsOfFile:imageFile];
		UIImage *currentUIImage=[self currentUIImage];
		int orientation=[currentUIImage imageOrientation];
		
 		UIImageWriteToSavedPhotosAlbum (grayscaleImage(image,orientation), self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
		
		return;
	}
		
	if (anIndex==sheet.numberOfButtons-1){
		anIndex=sheet.cancelButtonIndex-1;
	}
		
	%orig;
		
}
%end
%end


%group olderVersions
%hook PLAlbumsController
	
%new(v@:@@^v)-(void)myImage:(UIImage *)image didFinishSavingWithError:(NSError *) error contextInfo:(void*)contextInfo{
	

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


-(void)actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(int)anIndex{
	
	if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
		hud=[[UIProgressHUD alloc] init] ;
		[hud setText:@"Converting Image..."];
		[hud showInView:[[self currentImageView] window]];
	}
	
	if (anIndex==sheet.numberOfButtons-1){
		anIndex=sheet.cancelButtonIndex-1;
	}
	
	%orig;
				
}


-(void)actionSheet:(UIActionSheet *)sheet didDismissWithButtonIndex:(int)anIndex{
	

	
	if ([sheet isEqual:mySheet] && [[sheet buttonAtIndex:anIndex]  isEqual:[[sheet buttons] lastObject]]){
		
		NSString *imageFile=[[self currentImage] pathForOriginalFile];
		UIImage *image=[UIImage imageWithContentsOfFile:imageFile];
		UIImage *currentUIImage=[[self currentUIImage] retain];
		int orientation=[currentUIImage imageOrientation] ;
		
 		UIImageWriteToSavedPhotosAlbum (grayscaleImage(image,orientation), self, @selector(myImage:didFinishSavingWithError:contextInfo:), nil);
		
		
	}
	
	if (anIndex==sheet.numberOfButtons-1){
		anIndex=sheet.cancelButtonIndex-1;
	}
		
	%orig;
	
	
}
%end
%end

%hook UIActionSheet

-(void)presentSheetInView:(id)view { 

	if ([[[[self buttons] objectAtIndex:0] title] isEqualToString:[[NSBundle bundleWithIdentifier:@"com.apple.PhotoLibrary"] localizedStringForKey:@"SEND_PHOTO_VIA_EMAIL_BUTTON" value:nil table:@"Main"]] || [[[[self buttons] objectAtIndex:0] title] isEqualToString:[[NSBundle bundleWithIdentifier:@"com.apple.PhotoLibrary"] localizedStringForKey:@"SEND_PHOTO_VIA_EMAIL_BUTTON" value:nil table:@"PhotoLibrary"]]) {
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


__attribute__((constructor)) void GrayPixInit(){
	
	%init;
	if (!objc_getClass("MLPhoto") && [NSFileManager instancesRespondToSelector:@selector(URLForUbiquityContainerIdentifier:)]){
		%init(IOS5);
	}
	else if ([objc_getClass("MLPhoto") instancesRespondToSelector:@selector(pathForImageFile)]){
		%init(newerVersions);
	}
	else{
		%init(olderVersions);
	}

}

