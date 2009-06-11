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

#include <highgui.h>
#include <cv.h>

#include <iostream>

#include "smalllib.h"
/*
 *
 */

#define FILE_AVI "video/q3.avi"
#define MAX_NUM_ERROR 5
#define MAX_NUM_POINTS	1

void on_mouse(int event, int x, int y, int flags, void* param);

using namespace std;

/////////global/////////
CvPoint tracePoint, tracePoint_new;
bool isSetPoint	= false;
////////////////////////


int main(int argc, char** argv) {
	char* status = 0;

    IplImage* frame = 0;
    IplImage* drawFrame = 0;
    IplImage* cutImage = 0;
    IplImage* cutImageGray = 0;
    CvCapture* capture;
    capture = cvCreateFileCapture(FILE_AVI);
    if( capture==0 ) {
        perror("Error create AVI File Capture\n");
        return -1;
    }
    long num_of_frames = 0;
    cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,1.0);
    //num_of_frames = cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_COUNT);
    num_of_frames = cvGetCaptureProperty(capture,CV_CAP_PROP_POS_FRAMES);
    cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,0.);
    printf("num of frames = %d\n",(int)num_of_frames);

    cvNamedWindow("test", CV_WINDOW_AUTOSIZE);
    cvNamedWindow("cut", CV_WINDOW_AUTOSIZE);
    cvNamedWindow("canny",CV_WINDOW_AUTOSIZE);


    int current_frame=1;
    int err_count = 0;
    CvSize frameSize = cvSize(
            cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_WIDTH),
            cvGetCaptureProperty(capture,CV_CAP_PROP_FRAME_HEIGHT));

    CvPoint cutP1 = cvPoint(frameSize.width/5,frameSize.height/4);
    CvPoint cutP2 = cvPoint(3*frameSize.width/4,3*frameSize.height/4);
    CvSize  cutS  = cvSize(cutP2.x-cutP1.x, cutP2.y-cutP1.y);
    CvRect  cutRect = cvRect(cutP1.x, cutP1.y, cutS.width, cutS.height);
    //create Cut-Image
    cutImage = cvCreateImage(cutS,8,3);
    cutImageGray = cvCreateImage(cutS,8,1);
    // create cut-Image for Lukas-Kanade OF algorithm
    IplImage* cutPyrGray	= cvCreateImage(cutS,8,1);
    IplImage* cutPyrGray_old	= cvCreateImage(cutS,8,1);
    IplImage* swap_temp		=  cvCreateImage(cutS,8,1);
    IplImage* cutImageGray_old = cvCreateImage(cutS,8,1);
    CvPoint2D32f* tracePoints[2] = {0,0}, *swap_points;
    tracePoints[0] = (CvPoint2D32f*)cvAlloc(MAX_NUM_POINTS*sizeof(tracePoints[0][0]));
    tracePoints[1] = (CvPoint2D32f*)cvAlloc(MAX_NUM_POINTS*sizeof(tracePoints[0][0]));

    int win_siz = 7;
    int flags = 0;
    status = (char*)cvAlloc(MAX_NUM_POINTS);

    bool isRunOF	= false;

    //setup mouse callback
    cvSetMouseCallback("cut",on_mouse,0);
    //create mem-structure for receive lines hough-transform
    IplImage* cannyImage	= cvCreateImage(cutS,8,1);
    CvMemStorage* storage   = cvCreateMemStorage(0);
    CvSeq*  lines = 0;


    tracePoint = cvPoint(cutS.width/2,cutS.height/2);
    CvPoint tracePointArr_new = cvPoint(tracePoint_new.x,tracePoint_new.y);
    CvPoint tracePointArr = cvPoint(tracePoint_new.x,tracePoint_new.y);
    tracePoints[0][0] = cvPoint2D32f((double)tracePoint.x,(double)tracePoint.y);
    tracePoints[1][0] = cvPoint2D32f((double)tracePoint.x,(double)tracePoint.y);


    while(1) {
        //printf("current frame is [%d]\n",current_frame);
        //fflush(0);
        frame = cvQueryFrame(capture);
        if(++current_frame > num_of_frames) {
            current_frame = 1;
            cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,0.);
        }
        if(frame==0) {
            fprintf(stderr,"Bad Query frame [%d]\n",current_frame);
            if(++err_count >MAX_NUM_ERROR ) {
                printf("Max number of bad-frame limited [%d], exiting...",MAX_NUM_ERROR);
                break;
            }
            continue;
        }
        err_count=0;
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
        //cvCopyImage(drawFrame,cutImageGray);
        cvCvtColor(cutImage,cutImageGray,CV_RGB2GRAY);
        // make cut-area colorised
        cvAddS(drawFrame,cvScalar(50),drawFrame);
        cvResetImageROI(drawFrame);

        // make hough lines
        cvCanny(cutImageGray,cannyImage,100,200,3);
//        cvThreshold(cutImageGray,cannyImage,50,200,CV_THRESH_BINARY);
        cvShowImage("canny",cannyImage);

        lines = cvHoughLines2(cannyImage,storage,CV_HOUGH_PROBABILISTIC, 1, CV_PI/180, 50, 50, 10);
#if 0
        cout << "fuck1" << endl;
#else
        cout << "fuck2" << endl;
#endif
        cout << "Num of lines: " << lines->total << endl;
        /*
        for( int ii=0; ii< lines->total; ii++) {
            CvPoint* line = (CvPoint*) cvGetSeqElem(lines, ii);
            cvLine(cutImage, line[0], line[1], CV_RGB(0,255,0), 1, CV_AA, 0);
            cout << "line ["
				<< line[0].x << "," << line[0].y
				<< "] <---> ["
				<< line[1].x << "," << line[1].y << "]" << endl;
        }
        cvClearMemStorage(storage);
        */

        if(isSetPoint) {
        	tracePoints[0][0] = cvPointTo32f(tracePoint);
        	cvFindCornerSubPix(cutImageGray_old,
        			tracePoints[0],
        			1,
        			cvSize(win_siz,win_siz),
        			cvSize(-1,-1),
        			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03));
        	isSetPoint = false;
        }

        if(isRunOF) {
        	cvCalcOpticalFlowPyrLK(cutImageGray_old,cutImageGray,
        			cutPyrGray_old, cutPyrGray,
        			tracePoints[0],
        			tracePoints[1],
        			1,
        			cvSize(win_siz,win_siz),
        			3,
        			status,
        			0,
        			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03),
        			flags);
        	flags |= CV_LKFLOW_PYR_A_READY;
        	cout << "TRUE" << endl;
        	drawSquareBox(cutImage,cvPointFrom32f(tracePoints[0][0]),1,CV_RGB(255,0,0),1);
        	drawSquareBox(cutImage,cvPointFrom32f(tracePoints[1][0]),1,CV_RGB(255,0,0),1);
        }
        cout << "point0 [" << tracePoints[0][0].x << ":" << tracePoints[0][0].y << "] "
        << "point1 [" << tracePoints[1][0].x << ":" << tracePoints[1][0].y << "] " << endl;
        //cvDrawRect(cutImage,cvRect(tracePoint.x-1,tracePoint.y-1,2,2));
        cvRectangle(cutImage,cvPoint(tracePoint.x-2,tracePoint.y-2),cvPoint(tracePoint.x+2,tracePoint.y+2),CV_RGB(0,0,255));

        cvShowImage("cut",cutImage);
        cvShowImage("test",drawFrame);
//////////////////////////////////
        int key_press = cvWaitKey(100);
        if(key_press == 'r' || key_press == 'R') {
        	if (isRunOF)
        		isRunOF = false;
        	else
        		isRunOF = true;
        }
        if(key_press==27 || key_press=='q' || key_press=='Q') {
            printf("Pressed key [%c], exiting...\n",key_press);
            break;
        }
        CV_SWAP(cutImageGray_old,cutImageGray_old,swap_temp);
        CV_SWAP(cutPyrGray_old,cutPyrGray,swap_temp);
        CV_SWAP(tracePoints[0],tracePoints[1],swap_points);
    }


    //cvReleaseImage(&frame);
    cvReleaseCapture(&capture);
    cvDestroyWindow("canny");
    cvDestroyWindow("test");
    cvDestroyWindow("cut");
    return (EXIT_SUCCESS);
}

void on_mouse(int event, int x, int y, int flags, void* param) {
/////////////
    switch (event) {
        case CV_EVENT_LBUTTONDOWN:
            cout << "[" << x <<  "," << y << "]" << endl;
            tracePoint=cvPoint(x,y);
            isSetPoint = true;
            break;
        case CV_EVENT_LBUTTONUP:
            break;
    }
}

