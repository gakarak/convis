//============================================================================
// Name        : opencvCVSproject.cpp
// Author      : AR
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================


#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#include <highgui.h>
#include <cv.h>
#include <cxcore.h>

#include <iostream>

#include "smalllib.h"
/*
 *
 */

#define FILE_AVI "video/q3.avi"
#define MAX_NUM_ERROR 5
#define MAX_NUM_POINTS	1
#define WAIT_KEY_TIME	70
#define NUM_OF_LOOP		5
#define NUM_INIT_STEPS	5

#define DEBUG

static const bool USE_CAMERA	= true;
static const int CAMERA_NUM		= 0;

void on_mouse(int event, int x, int y, int flags, void* param);

using namespace std;

/////////global/////////
bool isExiting = false;

// drawing frame for extracting
CvPoint p0, p1;
bool isSelectFrame = false;
// true if Frame selected and created (after mouse LB UP)
bool isSelectedFrameCreated	= false;
// for free memory for array OF
bool isMustFreeArray	= false;
// for create additional array for OF
bool isMustCreateArray	= false;

// enable/disable drawing of CvPoint Array
bool isDrawingPointArray = false;

// pause for capturing images
bool isPaused	= false;

// Size of pixel grid for Optical Flow
// win_size = size of window for OF algorithms
int win_siz = 10;


CvSize gridSize = cvSize(10,10);
CvPoint*	arrayGridPoint	= 0;
CvPoint*	arrayFgrid		= 0;
CvPoint*	arrayFgrid_old	= 0;
CvPoint*	swap_CvPoint	= 0;

//CvPoint2D32f*	arrayGridPoint2D32F	= 0;
CvPoint2D32f*	arrayFgrid2D32F		= 0;
CvPoint2D32f*	arrayFgrid2D32F_old	= 0;
CvPoint2D32f*	arrayFgrid2D32F_start = 0;
CvPoint2D32f*	swap_CvPoint2D32F	= 0;
int			size_of_ArrayGridPoint	= 0;
int			size_of_arrayFgrid = 0;

// flag for cvCalcOpticalFlowPyrLK()
int of_flag		= 0;
// number of loop for OF
int count_of_loop	= 0;
////////////////////////

int init_steps_counter	= 0;
double	time_old = (0.000001*cvGetTickCount() / cvGetTickFrequency()),
		time_curr = 0;
CvPoint2D32f	vel = cvPoint2D32f(0.,0.);

char text_buf[100];
CvFont font;

int main(int argc, char** argv) {
	char* status = 0;

	cvInitFont(&font,CV_FONT_HERSHEY_PLAIN, 1, 1, 0.0, 1, CV_AA);

    IplImage* frame = 0;
    IplImage* drawFrame = 0;
    IplImage* cutImage = 0;
    IplImage* cutImageGray	= 0;
    IplImage* cutImageGray_old	= 0;
    IplImage* swap_image = 0;
    // additional images for OF methods
    IplImage* cutPyr		= 0;
    IplImage* cutPyr_old	= 0;

    CvCapture* capture;
    if(!USE_CAMERA) {
    	capture = cvCreateFileCapture(FILE_AVI);
    } else {
    	capture = cvCreateCameraCapture(CAMERA_NUM);
    }
    if( capture==0 ) {
        perror("Error create AVI File Capture\n");
        return -1;
    }
    long num_of_frames = 0;
    if (!USE_CAMERA) {
		cvSetCaptureProperty(capture, CV_CAP_PROP_POS_AVI_RATIO,1.0);
		num_of_frames = cvGetCaptureProperty(capture, CV_CAP_PROP_POS_FRAMES);
		cvSetCaptureProperty(capture, CV_CAP_PROP_POS_AVI_RATIO,0.);
		printf("num of frames = %d\n", (int) num_of_frames);
	}

    cvNamedWindow("cut", CV_WINDOW_AUTOSIZE);
    cvNamedWindow("test", CV_WINDOW_AUTOSIZE);
    cvNamedWindow("velx",CV_WINDOW_AUTOSIZE);


    int current_frame=1;
    int err_count = 0;
    CvSize frameSize = cvSize(
            cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_WIDTH),
            cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_HEIGHT));

    CvPoint cutP1 = cvPoint(frameSize.width/7,frameSize.height/7);
    CvPoint cutP2 = cvPoint(6*frameSize.width/7,6*frameSize.height/7);
    CvSize  cutSize  = cvSize(cutP2.x-cutP1.x, cutP2.y-cutP1.y);
    CvSize	cutPyrSize	= cvSize((cutSize.width+8),(1 + cutSize.height / 3));

    CvRect  cutRect = cvRect(cutP1.x, cutP1.y, cutSize.width, cutSize.height);
    //create Cut-Image
    cutImage = cvCreateImage(cutSize,8,3);
    cutImageGray	= cvCreateImage(cutSize,8,1);
    cutImageGray_old	= cvCreateImage(cutSize,8,1);
    cutPyr			= cvCreateImage(cutPyrSize,8,1);
    cutPyr_old		= cvCreateImage(cutPyrSize,8,1);
    // create cut-Image for Lukas-Kanade OF algorithm

//////// Init variables ////////
    IplImage* cutVelX			= cvCreateImage(cutSize,IPL_DEPTH_32F,1);
    IplImage* cutVelY			= cvCreateImage(cutSize,IPL_DEPTH_32F,1);
    IplImage* cutVelXAccum		= cvCreateImage(cutSize,IPL_DEPTH_32F,1);
    IplImage* cutVelYAccum		= cvCreateImage(cutSize,IPL_DEPTH_32F,1);
////////////////////////////////

    status = (char*)cvAlloc(MAX_NUM_POINTS);

    bool isRunOF	= false;

    //setup mouse callback
    cvSetMouseCallback("cut",on_mouse,0);
    //create mem-structure for receive lines hough-transform


    while(1) {
    	if (!isPaused) {
			frame = cvQueryFrame(capture);
			if ( (!USE_CAMERA) && (++current_frame > num_of_frames)) {
				current_frame = 1;
				cvSetCaptureProperty(capture, CV_CAP_PROP_POS_AVI_RATIO,0.);
			}
			if (frame == 0) {
				fprintf(stderr,"Bad Query frame [%d]\n", current_frame);
				if (++err_count > MAX_NUM_ERROR) {
					printf("Max number of bad-frame limited [%d], exiting...",
							MAX_NUM_ERROR);
					break;
				}
				continue;
			}
			err_count = 0;
    	}

//////////////////////////////////
        if(drawFrame != 0) {
            cvReleaseImage(&drawFrame);
        }
        // draw frame and rectangle on it
        drawFrame = cvCloneImage(frame);
        drawCentrafBox(drawFrame,
                cutP1,
                cutP2,
                CV_RGB(255,0,0),
                2);
        cvSetImageROI(drawFrame,cutRect);
        cvCopyImage(drawFrame,cutImage);
        cvCvtColor(cutImage,cutImageGray,CV_RGB2GRAY);
        // make cut-area colorised
        cvAddS(drawFrame,cvScalar(50),drawFrame);
        cvResetImageROI(drawFrame);
        cvPutText(drawFrame,"Test OF",cvPoint(100,100),&font,CV_RGB(255,0,255));


///////////////// Initialization Block /////////////////////

         if (init_steps_counter < NUM_INIT_STEPS) {
        	if (init_steps_counter == 0) {
				cvCopyImage(cutImageGray,cutImageGray_old);
				init_steps_counter++;
				continue;
			}
        	cout << "::Init[" << init_steps_counter << "]" << endl;
        	cvCalcOpticalFlowLK(cutImageGray_old,
        			cutImageGray,
        			cvSize(1,1),
        			cutVelX,
        			cutVelY);
        	cvAdd(cutVelX,cutVelXAccum,cutVelXAccum);
        	cvAdd(cutVelY,cutVelYAccum,cutVelYAccum);
        	double ret = cvGetReal2D(cutVelXAccum,100,100);
        	cout << "ret=[" << ret << "]" <<endl;
        	/*
        	uchar*	ptr = (uchar* )(cutVelX->imageData + 10*cutVelX->widthStep);
        	float vx = (float)ptr[50];
        	ptr = (uchar* )(cutVelY->imageData + 10*cutVelY->widthStep);
        	float vy = (float)ptr[50];
        	cout << "vx=" << vx << ", vy=" << vy << endl;
        	*/

        	cvShowImage("velx",cutVelXAccum);
			init_steps_counter++;
			int key = cvWaitKey(WAIT_KEY_TIME);
			if(key==27) {
				break;
			}
			CV_SWAP(cutImageGray_old,cutImageGray,swap_image);
			continue;
		}

//////////////////// End of INIT block /////////////////////

//////////// Manage memory for some array and structures /////////////
        // Free Array for OF
        if(isMustFreeArray) {
        	if(isSelectedFrameCreated) {
        		releasePointArray(arrayGridPoint);
        		size_of_ArrayGridPoint = 0;

        		releasePointArray(arrayFgrid);
        		releasePointArray2D32F(arrayFgrid2D32F);
        		releasePointArray2D32F(arrayFgrid2D32F_old);
        		releasePointArray2D32F(arrayFgrid2D32F_start);
        		size_of_arrayFgrid = 0;


        		cout << "free" << endl;
        	}
        	isMustFreeArray = false;
        }

        // Create Arrays for OF
        if(isMustCreateArray) {
        	if(isSelectedFrameCreated) {
            	size_of_ArrayGridPoint	= createPointArray(arrayGridPoint,p0,p1,gridSize);
            	size_of_arrayFgrid		= createCopyArray(arrayGridPoint,arrayFgrid,size_of_ArrayGridPoint);
            	arrayFgrid2D32F			= new CvPoint2D32f[size_of_arrayFgrid];
            	arrayFgrid2D32F_old		= new CvPoint2D32f[size_of_arrayFgrid];
            	arrayFgrid2D32F_start	= new CvPoint2D32f[size_of_arrayFgrid];

            	convertArrayFromIntTo2d32F(arrayGridPoint,arrayFgrid2D32F_old,size_of_arrayFgrid);
//            	convertArrayFromIntTo2d32F(arrayGridPoint,arrayFgrid2D32F,size_of_arrayFgrid);

            	count_of_loop = 0;
            	cout << "create" << endl;
        	}
        	isMustCreateArray = false;
        }
//////////// This you can place Algorithms ///////////
        if(!isEqualPoints(p0,p1)) {
        	drawCentrafBox(cutImage,p0,p1,CV_RGB(0,255,0),2);
        }

        if(isDrawingPointArray && isSelectedFrameCreated) {
        	drawPointsArray(cutImage,arrayGridPoint,size_of_ArrayGridPoint,CV_RGB(255,0,0));
//        	convertArrayFromIntTo2d32F(arrayGridPoint,arrayFgrid2D32F,size_of_arrayFgrid);

        	if(count_of_loop==0) {
        	cvFindCornerSubPix(cutImageGray_old,
        			arrayFgrid2D32F_old,
        			size_of_arrayFgrid,
        			cvSize(win_siz,win_siz),
        			cvSize(-1,-1),
        			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03));
        	createCopyArray2D32F(arrayFgrid2D32F_old,arrayFgrid2D32F_start,size_of_ArrayGridPoint);
        	}

        	cvCalcOpticalFlowPyrLK(cutImageGray_old,cutImageGray,
        			cutPyr_old, cutPyr,
        			arrayFgrid2D32F_old,
        			arrayFgrid2D32F,
        			size_of_arrayFgrid,
        			cvSize(win_siz,win_siz),
        			3,
        			status,
        			0,
        			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03),
        			of_flag);
        	//of_flag |= CV_LKFLOW_PYR_A_READY;
//        	convertArrayFrom2d32fToInt(arrayFgrid2D32F,arrayFgrid,size_of_arrayFgrid);
//        	drawPointsArray(cutImage,arrayFgrid,size_of_arrayFgrid,CV_RGB(0,0,255));
        	if(count_of_loop<NUM_OF_LOOP) {
        		count_of_loop++;
        		CV_SWAP(arrayFgrid2D32F_old,arrayFgrid2D32F,swap_CvPoint2D32F);
        	} else {
        		count_of_loop = 0;
        		/// Calc Velocity ///
        		if (!isPaused) {
					time_curr = 0.000001 * cvGetTickCount() / cvGetTickFrequency();
					vel = getVelocityPPS(arrayFgrid2D32F_start,
							arrayFgrid2D32F, size_of_arrayFgrid, time_old,
							time_curr);
					time_old = time_curr;
					cout << "vx=" << vel.x << ",  vy=" << vel.y << endl;
//					drawVelocity(cutImage,vel,cvPoint(30,30),10,CV_RGB(0,0,255),2);
				}
        		/// END /////////////
        		convertArrayFromIntTo2d32F(arrayGridPoint,arrayFgrid2D32F_old,size_of_arrayFgrid);
        	}
        	convertArrayFrom2d32fToInt(arrayFgrid2D32F,arrayFgrid,size_of_arrayFgrid);
        	drawPointsArray(cutImage,arrayFgrid,size_of_arrayFgrid,CV_RGB(0,0,255));

        	// draw Vel. info
        	drawVelocity(cutImage,vel,cvPoint(50,50),50,CV_RGB(0,0,255),2);
        	bzero(text_buf,sizeof(text_buf));
        	sprintf(text_buf,"vx=%0.1fpps, vy=%0.1fpps, v=%0.1fpps", vel.x,vel.y,getModVel(vel));
        	cvPutText(cutImage,text_buf,cvPoint(60,50),&font,CV_RGB(0,0,255));
        }


        CV_SWAP(cutImageGray_old,cutImageGray,swap_image);
        CV_SWAP(cutPyr_old, cutPyr,swap_image);
//////////////////////////////////////////////////////
        cvShowImage("cut",cutImage);
        cvShowImage("test",drawFrame);
//////////////////////////////////
        int key_press = cvWaitKey(WAIT_KEY_TIME);
        if(key_press == 'r' || key_press == 'R') {
        	if (isRunOF)
        		isRunOF = false;
        	else
        		isRunOF = true;
        }
        if(key_press==32) {
        	if(isPaused)
        		isPaused = false;
        	else
        		isPaused = true;
        }
        if(key_press==27 || key_press=='q' || key_press=='Q' || isExiting) {
        	if (!isExiting) {
        		printf("Pressed key [%c], exiting...\n",key_press);
        	}
            break;
        }
        if(key_press=='d' || key_press=='D') {
        	if(isDrawingPointArray)
        		isDrawingPointArray = false;
        	else
        		isDrawingPointArray = true;
        }
    }

    //cvReleaseImage(&frame);
    cvReleaseCapture(&capture);
    cvDestroyWindow("test");
    cvDestroyWindow("cut");

    return (EXIT_SUCCESS);
}

void on_mouse(int event, int x, int y, int flags, void* param) {
/////////////

	if(isSelectFrame) {
		p1 = cvPoint(x,y);
	}

    switch (event) {
        case CV_EVENT_LBUTTONDOWN:
            cout << "[" << x <<  "," << y << "]" << endl;
            isSelectFrame = true;
            p0 = cvPoint(x,y);
            p1 = cvPoint(p0.x,p0.y);
            isSelectedFrameCreated = false;
            isMustFreeArray = true;
            break;
        case CV_EVENT_LBUTTONUP:
        	isSelectFrame = false;
        	if(!isEqualPoints(p0,p1)) {
        		isMustCreateArray = true;
        	}
        	isSelectedFrameCreated = true;
            break;
        case CV_EVENT_LBUTTONDBLCLK:
        	isExiting = true;
        	break;
    }
}


