//
//  ViewController.swift
//  Image Annotation
//
//  Created by Pradeep Kumar Yadav on 05/01/16.
//  Copyright © 2016 iosbucket. All rights reserved.
//

import UIKit

enum ImageEditModes:Int {
    case editModeDrawing
    case editModeText
}

class ViewController: UIViewController,UITextViewDelegate {

    @IBOutlet private weak var imgCorrection: UIImageView!

    //MARK: Variables
    private var viewInputText: UIView!
    private var txtCorrection: UITextView!
    private var lastPoint = CGPoint.zero
    private var pointerWidth: CGFloat = 5.0
    private var swiped = false
    private var editMode:ImageEditModes?
    private var tempOldImage: UIImage!
    
    internal var delegate:AnyObject?
    internal var imageToBeEdited: UIImage!
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the view for input and add on the self view
        viewInputText = UIView(frame:CGRectMake(0, 0, 33,40))
        viewInputText.backgroundColor = UIColor.blackColor()
        txtCorrection = UITextView(frame:CGRectMake(5,5,23,30) )
        txtCorrection.delegate = self
        txtCorrection.font = UIFont.systemFontOfSize(11.0)
        txtCorrection.textColor = UIColor.whiteColor()
        txtCorrection.backgroundColor = UIColor.clearColor()
        
        viewInputText.addSubview(txtCorrection)
        self.view.addSubview(viewInputText)
        viewInputText.hidden = true
        
        //add pan gesture for moving the input view
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        self.viewInputText.addGestureRecognizer(panGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
   
    /**
     This method is called when user will click on the pencil icon on the UI
     
     - parameter sender: bar button object
     */
    @IBAction func drawingItemClicked(sender: UIBarButtonItem) {
        tempOldImage = self.imgCorrection.image
        editMode = ImageEditModes.editModeDrawing
    }
    
    /**
     This method is called when user will click on the T icon on the UI
     
     - parameter sender: bar button object
     */
    @IBAction func textItemClicked(sender: UIBarButtonItem) {
        tempOldImage = self.imgCorrection.image
        editMode = ImageEditModes.editModeText
    }
    
    //MARK: TextView Delegates
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        let strCorrection = "\(textView.text) \(text)"
        let size = (strCorrection as NSString).sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(11.0)])
        let remainingWidth = UIScreen.mainScreen().bounds.width - viewInputText.frame.origin.x - 20
        
        viewInputText.frame = CGRectMake(viewInputText.frame.origin.x, viewInputText.frame.origin.y, txtCorrection.contentSize.width < remainingWidth ? size.width + 20 : remainingWidth + 10, (txtCorrection.contentSize.height < 30 ? 30 : txtCorrection.contentSize.height) + 10 )
        txtCorrection.frame = CGRectMake(txtCorrection.frame.origin.x, txtCorrection.frame.origin.y, txtCorrection.contentSize.width < remainingWidth ? size.width + 20 : remainingWidth + 10,(txtCorrection.contentSize.height < 30 ? 30 : txtCorrection.contentSize.height) + 10)
        return true
    }
    
    //MARK: Private functions

    /**
     This method will be called when user will click on the back button
     
     - parameter sender: buttonObject
     */
    @IBAction func saveButtonClicked(sender:UIButton) {
        if viewInputText.hidden == false {
            //Draw the text view on the image if it is not hidden
            UIGraphicsBeginImageContextWithOptions(viewInputText.bounds.size, true, 0)
            viewInputText.drawViewHierarchyInRect(viewInputText.bounds, afterScreenUpdates: true)
            let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //crate a uiimage from the current context and save it to camera roll.
            UIGraphicsBeginImageContextWithOptions(imgCorrection.bounds.size, true, 0)
            
            imgCorrection.image?.drawInRect(CGRect(x: 0, y: 0,
                width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
            imageWithText.drawInRect(viewInputText.frame)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }else
        {
            UIGraphicsBeginImageContext(imgCorrection.bounds.size)
            imgCorrection.image?.drawInRect(CGRect(x: 0, y: 0,
                width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    /**
     This method will be called when user will click on the cancel button in the UI while editing
     
     - parameter sender: button objects
     */
    func cancelClicked(sender:UIButton) {
        if editMode == ImageEditModes.editModeText {
            self.viewInputText.hidden = true
        }
        editMode = nil
        self.imgCorrection.image = tempOldImage
    }
    
    /**
     This method will be called when user will click on the done button in the UI while editing
     
     - parameter sender: button object
     */
    func doneClicked(sender:UIButton) {
        if editMode == ImageEditModes.editModeText {
            txtCorrection.editable = false
            txtCorrection.resignFirstResponder()
            viewInputText.endEditing(true)
        } else {
            UIGraphicsBeginImageContext(imgCorrection.bounds.size)
            imgCorrection.image?.drawInRect(CGRect(x: 0, y: 0,
                width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imgCorrection.image = image
        }
        editMode = nil
    }
    
    //MARK: Pan Gesture
    /**
    This method will be called when user will move the edited text.
    
    - parameter panGestureRecognizer: pangesture object
    */
    func handlePanGesture(panGestureRecognizer : UIPanGestureRecognizer) {
        let translation =  panGestureRecognizer.translationInView(self.imgCorrection)
        viewInputText.center = CGPointMake((panGestureRecognizer.view?.center.x)! + translation.x , (panGestureRecognizer.view?.center.y)! + translation.y)
        panGestureRecognizer.setTranslation(CGPointMake(0, 0), inView: self.imgCorrection)
    }
}


// MARK: - Class extension to implement the touch methods
extension ViewController {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if editMode == ImageEditModes.editModeDrawing {
            swiped = false
            //store the fisrt point where clicked
            if let touch = touches.first  {
                lastPoint = touch.locationInView(self.view)
            }
        } else if editMode == ImageEditModes.editModeText {
            //store the fisrt point where clicked and unhide the textview if hidden to capture the text
            if let touch = touches.first  {
                lastPoint = touch.locationInView(self.imgCorrection)
            }
            if viewInputText.hidden == true {
                self.viewInputText.hidden = false
                viewInputText.frame = CGRectMake(lastPoint.x, lastPoint.y, viewInputText.frame.size.width, viewInputText.frame.size.height)
                txtCorrection.becomeFirstResponder()
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if editMode == ImageEditModes.editModeDrawing {
            swiped = true
            
            // Draw a line in the image and display it
            if let touch = touches.first {
                let currentPoint = touch.locationInView(view)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if editMode == ImageEditModes.editModeDrawing {
            if !swiped {
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
            //Draw the line and create the image to set on the imageview
            
            UIGraphicsBeginImageContext(imgCorrection.frame.size)
            imgCorrection.image?.drawInRect(CGRect(x: 0, y: 0, width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height), blendMode: CGBlendMode.Normal, alpha: 1.0)
            imgCorrection.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    /**
     This function is called to draw a line between two points
     
     - parameter fromPoint: start point
     - parameter toPoint:   end point
     */
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        UIGraphicsBeginImageContext(imgCorrection.frame.size)
        let context = UIGraphicsGetCurrentContext()
        imgCorrection.image?.drawInRect(CGRect(x: 0, y: 0, width: imgCorrection.frame.size.width, height: imgCorrection.frame.size.height))
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, pointerWidth)
        CGContextSetRGBStrokeColor(context, 254.0/255.0 , 87.0/255.0,86.0/255.0, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        CGContextStrokePath(context)
        imgCorrection.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }


}

