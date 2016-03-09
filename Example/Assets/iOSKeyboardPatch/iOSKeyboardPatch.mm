//
//  iOSKeyboardPatch.mm
//  Unity-iPhone
//
//  Created by Masayuki Iwai on 2/5/16.
//  Copyright © 2016 myb design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Keyboard.h"

static const unsigned kToolBarHeight = 44;

@interface KeyboardDelegate () {
#if !UNITY_TVOS
    UIToolbar *viewToolbar;
    UIToolbar *fieldToolbar;
#endif
    UIView *editView;
    BOOL _multiline;
}

@end

@implementation KeyboardDelegate (iOSKeyboardPatch)

static BOOL isPatchApplied = NO;
CGFloat originalToolbarHeight = 0.0f;

+ (void)exchangePositionInputImplementations {
    // Exchange methods by method swizzling
    Method originalPositionInput = class_getInstanceMethod(self, @selector(positionInput:x:y:));
    Method patchedPositionInput = class_getInstanceMethod(self, @selector(_positionInput:x:y:));
    method_exchangeImplementations(originalPositionInput, patchedPositionInput);
}

+ (void)applyPatch {
    if(!isPatchApplied) {
        [self exchangePositionInputImplementations];

        // Override textViewShouldBeginEditing by method swizzling
        Method patchedTextViewShouldBeginEditing = class_getInstanceMethod(self, @selector(_textViewShouldBeginEditing:));
        IMP patchedTextViewShouldBeginEditingImplementation = method_getImplementation(patchedTextViewShouldBeginEditing);
        const char *patchedTextViewShouldBeginEditingTypes = method_getTypeEncoding(patchedTextViewShouldBeginEditing);
        class_replaceMethod(self, @selector(textViewShouldBeginEditing:),
                            patchedTextViewShouldBeginEditingImplementation, patchedTextViewShouldBeginEditingTypes);
        
        isPatchApplied = YES;
    }
}

+ (void)revertPatch {
    if(isPatchApplied) {
        [self exchangePositionInputImplementations];
        isPatchApplied = NO;
    }
}

- (void)setViewToolbarHeight:(CGFloat)height {
    CGRect viewToolbarFrame = viewToolbar.frame;
    viewToolbarFrame.size.height = height;
    viewToolbar.frame = viewToolbarFrame;
}

- (BOOL)_textViewShouldBeginEditing:(UITextView*)textView {
#if !UNITY_TVOS
    if(originalToolbarHeight == 0.0f) {
        originalToolbarHeight = viewToolbar.frame.size.height;
    }
    
    if(isPatchApplied) {
        [self setViewToolbarHeight:kToolBarHeight];
    } else {
        [self setViewToolbarHeight:originalToolbarHeight];
    }

    if(!textView.inputAccessoryView) {
        textView.inputAccessoryView = viewToolbar;
    }
#endif
    return YES;
}

- (void)_positionInput:(CGRect)kbRect x:(float)x y:(float)y {
    // Call original method
    [self _positionInput:kbRect x:x y:y];
    
    // Adjust frame
    CGRect editViewFrame = editView.frame;
    
    if(_multiline) {
        editViewFrame.origin.y = y - editViewFrame.size.height;
    } else {
        editViewFrame.origin.y = y - kToolBarHeight;
        editViewFrame.size.height = kToolBarHeight;
        
#if !UNITY_TVOS
        if([UIDevice currentDevice].systemVersion.floatValue < 7.0f) {
            // iOS 6.x or earlier
            CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
            editViewFrame.origin.y -= statusBarFrame.size.height;
        }
#endif
    }
    
    editView.frame = editViewFrame;
}

@end

extern "C" {
    void _iOSKeyboardPatch_apply() {
        [KeyboardDelegate applyPatch];
    }

    void _iOSKeyboardPatch_revert() {
        [KeyboardDelegate revertPatch];
    }
}
