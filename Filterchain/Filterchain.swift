//
//  FilterChain.swift
//  Randomizer
//
//  Created by Leo Stefansson on 22.12.2016.
//  Copyright © 2016 Generate Software Inc. All rights reserved.
//

import GPUImage
import AVFoundation
import Photos // We need this to save videos
import MobileCoreServices

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public class FilterChain:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - Variables
    var camera:Camera!
    var renderView:RenderView!
    
    //MARK: Still image capture
    let pictureOutput = PictureOutput()
    
    //MARK: Video capture
    var movieOutput : MovieOutput? = nil
    var isRecording = false // Indicates recording state (started/stopped), does NOT indicae file saving completion (
    var fileURL: URL? = nil
    
    
    ///Determines whether to apply crop filter to output
    var aspectRatioSquare = false
    let cropFilter = Crop();
    ///Rotation for Video:
    let rotation = TransformOperation()

    var filters: [FilterOperationInterface] = [FilterOperationInterface]() // This stores all available filters
    var activeFilters: [FilterOperationInterface] = [FilterOperationInterface]() // Filters currently in the chain
    var numFilters = 3 // Number of filters in chain
    
    var singleFilterCounter = 0
    
    //MARK: Callbacks
    var videoDidSave: ((_: Bool, _: URL)->())?
    var stillImageDidSave: ((_: Bool)->())?
    
    //MARK: Image Picker
    let picker = UIImagePickerController();
    var stillAsset: UIImage?;
    var videoAsset: AVURLAsset?;
    
    
    var currentInput:InputSource?
    /**
     The Input Source that is providingnthe image or capture to build the filterchain off of.
     - LibraryStill: Pictures from the Library
     - LibraryVideo: Videos from the Library
     - CameraStill: Camera mode to capture high resolution stills
     - CameraVideo: Camera mode to capture video
     */
    enum InputSource{
        case LibraryStill
        case LibraryVideo
        case CameraStill
        case CameraVideo
    }
    
    
    var cameraLocation:PhysicalCameraLocation = .backFacing
    var aspectRatioPreset = AVCaptureSessionPresetHigh
    
    override init(){
        super.init()
        picker.delegate = self
    }
    
    //MARK: - FilterChain Construction and Teardown
    
    /**
        Initialize all filter operations.
     */
    public func initFilters() {
        
        filters = [filterOperations[18], filterOperations[15], filterOperations[14]]
        
        activeFilters = filters
        
        for (index, operation) in filterOperations.enumerated() {
            print(String(index)+" "+operation.titleName)
        }
        
        let squareSize = Size(width: 700.0,height: 700.0);
        cropFilter.cropSizeInPixels = squareSize
    }
    
    /**
        Start the filter chain
     */
    public func start() {
        initFilters()
    }
    
    /**
     Pass the view from the ViewController
     */ 
    public func startCameraWithView(view: RenderView) {
        renderView = view
        startCamera();
    }
    /**
     Remove all targets from every filterchain elements
     */
    private func teardownChain() {
        camera.stopCapture()
        // Remove all targets from currently active filters and camera
        camera.removeAllTargets()
        
        // Remove targets from active filters
        for operation in activeFilters {
            operation.filter.removeAllTargets()
            
        }
        if (!aspectRatioSquare){
            cropFilter.removeAllTargets();
        }
        rotation.removeAllTargets();
    }
    
    /**
     Steps for each input source that needs to happen before the chain is rebuilt
     
     */
    func preBuildChainSteps(){
        if (currentInput == .CameraVideo || currentInput == .CameraStill){
            rebuildChain(sourceOrigin: camera);
            
        }
        else if (currentInput == .LibraryStill){
            //            rebuildChain(sourceOrigin: self.stillAsset!)
        }
        else if (currentInput == .LibraryVideo){
            //            rebuildChain(sourceOrigin: self.videoAsset!)
            videoPreProcess(videoAsset: self.videoAsset!);
        }
    }
    
    /**
        Internal method used to (re)build the chain up with the input specified.
        - warning: should only be used in conjunction with `preBuildChainSteps()`
        - parameter sourceOrigin: Takes the InputSouce that the chain will attach to. (Ex: Camera, Library Video, Library Still)
     */
    private func rebuildChain(sourceOrigin:ImageSource) {

        print("--------------------------- >>> Rebuilding chain")
//        camera.addTarget(activeFilters[0].filter)
        sourceOrigin.addTarget(activeFilters[0].filter)
        //filterOperations[0].filter.addTarget(renderView)
        print("camera --> \(activeFilters[0].titleName)")
        for (index, operation) in activeFilters.enumerated() {
            if index < activeFilters.count-1 {
                operation.filter.addTarget(activeFilters[index+1].filter)
                print("\(operation.titleName) --> \(activeFilters[index+1].titleName)")
            }
            else {
                if (aspectRatioSquare){

                    activeFilters[index].filter.addTarget(cropFilter);
                    print("\(operation.titleName)")
                    cropFilter.addTarget(renderView)
                    //cropToSquare.addTarget(pictureOutput)
                    if (movieOutput != nil) {
                        cropFilter.addTarget(movieOutput!)
                    }
                }
                else{

                    print("\(activeFilters[index].titleName) --> renderView")
                    activeFilters[index].filter.addTarget(renderView)
//                    activeFilters[index].filter.addTarget(pictureOutput)
                    
                    
                    
                    /// POST Chain actions:
                    if (movieOutput != nil) {
                        activeFilters[index].filter.addTarget(movieOutput!)
                        print(activeFilters[index])
                    }
                    if (currentInput == .LibraryStill){
                        (sourceOrigin as! PictureInput).processImage(synchronously:true)

                    }
        
                    
                    if (currentInput == .CameraStill || currentInput == .CameraVideo){
                        camera.startCapture()
                    }
                    
                }
            }
        }
    }
    
    // MARK: - FilterChain Modification
    /**
     Sets the new maximum allowable filters in the Filterchain to be active at one time
     - parameter newLength: The desired maximum allowable amount of filters in the filterchain
     */
    func setFilterChainLength(newLength: Int){
        //check ceiling and floor
        if (newLength > filters.count){
            numFilters = filters.count
        }
        else if (newLength <= 0){
            numFilters = 1
        }
        else{
            numFilters = newLength
        }
        
        // Rebuild chain
        rebuildChain(sourceOrigin: camera)
    }
    
    /**
     Returns the number of filters allowed to be active
     - returns: (Int) Number of Filters allowed to be active
     */
    func getFilterChainLength() -> Int{
        return numFilters
    }
    
    /**
     Removes the specified filter from the filterchain
     - parameter filterID: the id as specified in FilterOperations
     */
    //FIXME: Remove Filter needs to be divorced from utilizing only the camera
    //TODO: Omar's Changes: Inputs a method by ID, and appends to the chain
    func removeFilterAtIndex(index: Int){
        //Stop Camera Capture
        camera.stopCapture()
        
        //Remove specified target at index
        activeFilters.remove(at: index)
        
        // Decrement Number Filter
        setFilterChainLength(newLength: numFilters-1)
        
        //Rebuild Chain
        rebuildChain(sourceOrigin: camera)
        
        //Start camera capture
        camera.startCapture()
    }
    
    /**
     Adds a filter to the activeFilters
     - parameter filterID: the id as specified in FilterOperations
     */
    //FIXME: Append Filter needs to be divorced from utilizing only the camera
    //TODO: Omar's Changes: Inputs a method by ID, and appends to the chain
    func appendFilter(filter:Int){
        //Stop Camera Capture
        camera.stopCapture()
        
        //Add to end of active filters
        //        activeFilters.append(filter)
        activeFilters.append(filters[filter])
        
        //Increment Number filter
        setFilterChainLength(newLength: numFilters+1)
        
        //Rebuild Chain
        rebuildChain(sourceOrigin: camera)
        
        //Start camera capture
        camera.startCapture()
    }
    
    /**
     Picks several random filters in the FilterOperations array and adds it to ActiveFilters
     */
    public func randomizeFilterChain() {
        print("RANDOMIZING")
        teardownChain()
        
        
        var indexArray = [Int]()
        while indexArray.count < activeFilters.count {
            let randNum = randomIndex()
            if (!indexArray.contains(randNum)) {
               indexArray.append(randNum)
            }
        }
        print("indexArray \(indexArray)")
        for (index, newIndex) in indexArray.enumerated() {
            activeFilters[index] = filterOperations[newIndex]
        }
        

        preBuildChainSteps()
        
    }
    /**
     Switches to the next filter available in filterOperations and appends it to ActiveFilters
     */
    public func nextFilterAvailable(){
        teardownChain()
        
        activeFilters.removeAll()

        activeFilters.append(filterOperations[singleFilterCounter])
        if (singleFilterCounter < filterOperations.count){
            singleFilterCounter+=1
        }
        else{
            singleFilterCounter = 0
        }
        preBuildChainSteps()
    }
    
    
 
    
    /**
        Return a random filter index
     */
    private func randomIndex() -> Int {
        let count = filterOperations.count
        let randNum = Int(arc4random_uniform(UInt32(count)))
        print("randNum=\(randNum)")
        return randNum
    }
    
    private func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        return arr
    }
    
    // MARK: - Capture
    
    /**
     Internal function to capture a still and set up the callback
    */
    public func captureStill() {
        print("FC -> Capture Still")
        pictureOutput.encodedImageFormat = .png
        pictureOutput.imageAvailableCallback = {image in
            print("FC -> image available callback")
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(FilterChain.image(_:didFinishSavingWithError:contextInfo:)) , nil)
        }
    }
    
    
    //HELLO DO NOT ADD @objc EVEN THOUGH THE COMPILER SAYS TO OTHERWISE YOU WILL BREAK THINGS
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        let success:Bool?
        if let error = error {
            success = false
            // we got back an error!
            print("FC -> Error saving image -> \(error)")
            
        } else {
            print("FC -> Image saved successfully")
            success = true
        }
        self.stillImageDidSave?(_:success!)
    }
    
    /**
        Video Capture toggle (start/stop)
     */
    public func captureVideo() {
        print("FC -> Start Capture Video")
        
        if (!isRecording) {
            do {
                self.isRecording = true
                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
                let currentDateTime = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-mm-dd_hh:mm:ss"
                print("Capture At:\(dateFormatter.string(from: currentDateTime))")
                
                self.fileURL = URL(string:"test_\(dateFormatter.string(from: currentDateTime)).mp4", relativeTo:documentsDir)!
                do {
                    try FileManager.default.removeItem(at:self.fileURL!)
                } catch {
                }
                print("Here comes the URL...")
                print(self.fileURL?.absoluteString ?? "no file URL found!")
                movieOutput = try MovieOutput(URL:fileURL!, size:Size(width:480, height:640), liveVideo:true)
                camera.audioEncodingTarget = movieOutput
                activeFilters[activeFilters.count-1].filter --> movieOutput!
                movieOutput!.startRecording()
            } catch {
                fatalError("Couldn't initialize movie, error: \(error)")
            }
        } else {
            self.isRecording = false
            movieOutput?.finishRecording{
                print("FC -> Video recording finished")
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.fileURL!)
                }, completionHandler: { success, error in
                    print("Video recording completed with error = " + String(describing: error))
                    // Notify the videoDidSave callback of the results
                    self.videoDidSave?(_:success, _:self.fileURL!)
                })
                
                DispatchQueue.main.async {
                  //  (sender as! UIButton).titleLabel!.text = "Record"
                }
                self.camera.audioEncodingTarget = nil
                self.movieOutput = nil
            }
        }
    }
    

    
    //MARK: - Inputs (Camera, Still, Video)
    
    
    /**
     Switches the camera to the one not in use. (i.e.:/ If front facing camera is active, this method will switch to the rear facing camera)
     # Dev Notes:
     - AVCaptureSessionPhoto = 3:4 -- currently doesn't work properly, captures at 3:4 res but at potato quality
     - AVCaptureSessionHigh = Highest Resolution on screen (so usually 16:9 on newer phones)
    */
    func flipCamera(){
        if (cameraLocation == .backFacing){
            cameraLocation = .frontFacing
        }
        else {
            cameraLocation = .backFacing
        }
        startCamera()
    }
    
    /**
     Changes the aspect ratio used by the camera, and invokes startCamera()
     - parameter newRatio: The new Aspect Ratio to set (accepts 3:4, or 1:1, otherwise defaults to 16:9)
    */
    
    func changeAspectRatio(newRatio:String){
        switch newRatio{
        case "3:4":
            aspectRatioSquare = false;
            aspectRatioPreset = AVCaptureSessionPresetPhoto
        case "1:1":
            aspectRatioSquare = true;
            aspectRatioPreset = AVCaptureSessionPresetHigh
        default:
            aspectRatioSquare = false
            aspectRatioPreset = AVCaptureSessionPresetHigh
            
        }
        startCamera()
    }
    
    /**
        - Sets the current Input to .CameraVideo
        - Tears the chain down
        - Takes the current parameters set by changeAspectRatio() and flipCamera() and initializes the camera
     */
    func startCamera(){
        currentInput = .CameraVideo
        
        
        
        if (camera != nil){
            teardownChain();
        }

        do{

            camera = try Camera(sessionPreset:aspectRatioPreset, location: cameraLocation)
            camera.runBenchmark = false
            //            camera.delegate = self
            rebuildChain(sourceOrigin: camera)
            camera.startCapture()
            
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }

        
    }

    //MARK: - Image Picker Delegates
    
    /**
     The callback initiated by the iOS Library picker after a user selects a asset from the library
     - Determines if the asset is Stil or Video
     - References a global variable to the asset for later use
     - Orients the image or video properly via `fixedOrientation()` extension or `videoPreProcess()`
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let mediaType = info[UIImagePickerControllerMediaType] as? NSString
        
        teardownChain();

        
        if (mediaType!.isEqual(to: String(kUTTypeImage))){
//        if (mediaType == String(kUTTypeImage)){
            if let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.fixedOrientation() {
                
                
                //Retain a copy of the image for future processing
                stillAsset = image;
//                addFilterOnStillAsset()
//                stillAssetFilterChainBuilder();
                currentInput = .LibraryStill
                rebuildChain(sourceOrigin: PictureInput(image: image))
                print("went ok");
            } else{
                print("Something went wrong")
            }
        }
        else  if (mediaType!.isEqual(to: String(kUTTypeMovie))){
            currentInput = .LibraryVideo
            let movieURL = info[UIImagePickerControllerReferenceURL] as? URL
//            let videoAsset = AVURLAsset.init(url: movieURL!)
//            rebuildChain(ImageOrigin: AVURLAsset.init(url: movieURL!))
            
            
            //Retain a global copy of the asset for future use
            videoAsset = AVURLAsset.init(url: movieURL!)
            
            //Go to preprocess
            videoPreProcess(videoAsset: self.videoAsset!);
            
            
//            addFilterOnVideoAsset();
            
            // In the future we have to take input, for now we will code some random-ness
           

            
        }
    }
    /**
     The Callback initiated by the iOS Media Library if the user cancels picking an image.
     */
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    /**
     Preprocesses a video such that it is in the right orientation for viewing on screen. Rebuilds the Chain and Starts video playback.
     - parameter videoAsset: The AVURLAsset that needs to be processed
     */
    func videoPreProcess(videoAsset: AVURLAsset){
        do{
            
            //                print ("video orientation \(readMovieAsset.videoOrientation().orientation)")
            let orientation = videoAsset.videoOrientation();
            let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0];
            print("preferred transform \(videoTrack.preferredTransform)")
            
            
            
            let size = (videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]).naturalSize;
            
            print("width \(size.width) height \(size.height)")
            
            
            
            let movie = try MovieInput(url: (videoAsset.url), playAtActualSpeed: true, loop: true)
            
            
            // Special Sauce for Rotating Videos back to Portrait Orientation
            //                let inputRotation = Rotation.rotateClockwise;
            
            //                rotation.transform = Matrix4x4(CGAffineTransform(rotationAngle: -90.0));
            
            if (orientation == .portrait){
                self.rotation.overriddenOutputRotation = .rotateCounterclockwise
                self.rotation.overriddenOutputSize = Size(width: 1080.0, height: 1920.0)
                
            }
            else if (orientation == .portraitUpsideDown){
                self.rotation.overriddenOutputRotation = .rotateClockwise
                self.rotation.overriddenOutputSize = Size(width: 1080.0, height: 1920.0)
            }
            else if (orientation == .landscapeLeft){
                self.rotation.overriddenOutputRotation = .rotate180
                //                    rotation.overriddenOutputSize = Size(width: 1080.0, height: 1920.0)
            }
            
            
            movie.addTarget(rotation)
            
            rebuildChain(sourceOrigin: rotation);
            
            //Note: This is technically a post chain build action, but leaving it here for now as otherwise the movie won't start elsewhere
            movie.start();
        }
        catch{
            
        }
    }
  
}
