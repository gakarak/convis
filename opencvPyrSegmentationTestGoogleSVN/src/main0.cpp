/*
 * main.cpp
 *
 *  Created on: 26.03.2009
 *      Author: ar
 */


#include <iostream>
#include <stdlib.h>
#include <stdio.h>
//OpenCV
#include <cv.h>
#include <highgui.h>
#include "simplemath.h"
#include "smalllib.h"

#define WINORIG		"original"
#define WINSEGM		"testPyrSegmentation"
#define delay		100
#define BAD_CAPTURE_COUNT		5
#define SCALE_FACTOR	2


#define USE_MEAN_SHIFT	1
#define USE_CAMERA	false

#define CAM_NUM		0
#define avi_file	"video/q3.avi"
#define trackbar_thr1	"Thr1"
#define trackbar_thr2	"Thr2"
#define trackbar_npyr	"Npyr"

#ifndef USE_MEAN_SHIFT
	#define THRESH1_COUNT	500
	#define THRESH2_COUNT	500
	#define THRESH1_DEF	200
	#define THRESH2_DEF	50
	#define NPYR_COUNT	10
	#define NPYR_DEF	3
#else
	#define THRESH1_COUNT	200
	#define THRESH2_COUNT	200
	#define THRESH1_DEF	20
	#define THRESH2_DEF	40
	#define NPYR_COUNT	10
	#define NPYR_DEF	2
#endif


int threshold1	=	THRESH1_DEF;
int threshold2	=	THRESH2_DEF;
int npyr		=	NPYR_DEF;

static int	num_of_frames	= 0;

int main( int argc, char* argv[] ) {
	cvNamedWindow(WINORIG, CV_WINDOW_AUTOSIZE);
	cvNamedWindow(WINSEGM, CV_WINDOW_AUTOSIZE);

	cvCreateTrackbar(trackbar_thr1,WINSEGM,&threshold1,THRESH1_COUNT,0);
	cvCreateTrackbar(trackbar_thr2,WINSEGM,&threshold2,THRESH2_COUNT,0);
	cvCreateTrackbar(trackbar_npyr,WINSEGM,&npyr,NPYR_COUNT,0);


	CvCapture*	capture;
	if(USE_CAMERA) {
		capture = cvCreateCameraCapture(0);
	} else {
		capture = cvCreateFileCapture(avi_file);
	}

	if(!capture) {
		cerr << "Error: create capture" << endl;
		return -1;
	}

	if(!USE_CAMERA) {
		cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,1.0);
		num_of_frames = cvGetCaptureProperty(capture, CV_CAP_PROP_POS_FRAMES) - 1;
		cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,0.);
		cout << "num of frames = " << num_of_frames << endl;
//		return 0l;
	}

	IplImage*	img = NULL;
//	IplImage*	imgSegm	= NULL;
	IplImage*	img_segm_res = NULL;
	IplImage*	img_res = NULL;
	int key	= 0;
	int err_captue_count = 0;
	CvMemStorage* storage	= cvCreateMemStorage(0);
	CvSeq*	comp = NULL;
	bool isInitialization	= true;
	CvSize	sizeImgSegm;
	CvFont	font;
	cvInitFont(&font,CV_FONT_HERSHEY_PLAIN, 1, 1, 0.0, 1, CV_AA);

	double fps=0.0, fps_average=0.0;
	int counter = 0;
	int current_frame	= 1;

	long double time_beg, time_curr, time_old;
//////////////////////////////////////////
	while(1) {

		img = cvQueryFrame(capture);
		if(!img) {
			cerr << "bad frame [" << err_captue_count++ << "]" << endl;
			if(err_captue_count>BAD_CAPTURE_COUNT) {
				cerr << "to many error in capture, exiting..." << endl;
				break;
			}
			continue;
		}; err_captue_count=0;

		if((!USE_CAMERA) && (++current_frame>num_of_frames)) {
			current_frame = 1;
			cvSetCaptureProperty(capture,CV_CAP_PROP_POS_AVI_RATIO,0.);
		}

		if(isInitialization) {
			cout << "::: Initialization :::" << endl;
			if(SCALE_FACTOR != 1) {
				CvSize tmp = cvGetSize(img);
				sizeImgSegm = cvSize(tmp.width/SCALE_FACTOR, tmp.height/SCALE_FACTOR);
				img_segm_res = cvCreateImage(sizeImgSegm,img->depth,img->nChannels);
				img_res = cvCreateImage(sizeImgSegm,img->depth,img->nChannels);
			} else {
				img_segm_res = cvCreateImage(cvGetSize(img),img->depth,img->nChannels);
				img_res = img;
			}
			time_beg = cvGetTickCount()/cvGetTickFrequency();
			//time_curr = cvGetTickCount()/cvGetTickFrequency();
			time_old = cvGetTickCount()/cvGetTickFrequency();
			cout << "::: End of Init :::" << endl;
			isInitialization = false;
		}

		// Try delete digital noise
		cvSmooth(img,img,CV_GAUSSIAN,7,7);
		if(SCALE_FACTOR!=1) {
			cvResize(img, img_res, CV_INTER_LINEAR);
			//cvResize(img, img_segm_res, CV_INTER_LINEAR);
		}
//		cvPyrMeanShiftFiltering(img_res,img_segm_res,20,40,2);
//		cout << threshold1 << ":" << threshold2 << ":" << npyr << endl;

#ifdef USE_MEAN_SHIFT
		cvPyrMeanShiftFiltering(img_res,img_segm_res,threshold1,threshold2,npyr);
#else
		cvPyrSegmentation(img_res,img_segm_res,storage,&comp,npyr, threshold1, threshold2);
		int n_comp	= comp->total;
		if (!((++counter)%10)) cout << "Num of components :" << n_comp << "  [" << counter << "]" << endl;
#endif



		char buff[100];
		bzero(buff,sizeof(buff));

		time_curr = cvGetTickCount()/cvGetTickFrequency();
		fps = 1000000/(time_curr - time_old);
		time_old = time_curr;
		fps_average = counter*1000000/(time_curr - time_beg);
		sprintf(buff,"FPS=%0.1f, <FPS>=%0.1f",fps,fps_average);
		cvPutText(img_segm_res,buff,cvPoint(5,30),&font,CV_RGB(255,0,0));
		cvShowImage(WINORIG, img);
		cvShowImage(WINSEGM, img_segm_res);

		key	= cvWaitKey(delay);
		if( key == 27 || key == 'q' || key == 'Q') {
			cout << "Exiting ..." << endl;
			break;
		}
		cvClearMemStorage(storage);
		//cvReleaseMemStorage(&storage);
	}

	cvDestroyWindow(WINORIG);
	cvDestroyWindow(WINSEGM);
	cvReleaseCapture(&capture);
//	cvReleaseImage(&img);
	cvReleaseImage(&img_segm_res);
	return 0;
}
