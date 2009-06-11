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

#define NUMR	4
#define NUMF	18

#define NUMX	5
#define NUMY	5

//#define imcd0	"img/cd0.jpg"
//#define imcd1	"img/cd1.jpg"
#define imcd0	"img/fcd0.png"
#define imcd1	"img/fcd1.png"

CvSize imSize = cvSize(800,600);
static double rmax = 1;
static double rmin = 0;

static double lx	= 0.;
static double ly	= 0.;

int main( int argc, char* argv[] ) {

	//IplImage* img = cvCreateImage(imSize,IPL_DEPTH_8U,3);
	IplImage* img = cvLoadImage(imcd0,CV_LOAD_IMAGE_UNCHANGED);
	IplImage* imgA = cvLoadImage(imcd0,CV_LOAD_IMAGE_GRAYSCALE);
	IplImage* imgB = cvLoadImage(imcd1,CV_LOAD_IMAGE_GRAYSCALE);
	imSize = cvSize(img->width,img->height);
	rmax=0.8*((imSize.width>imSize.height)?imSize.height/2:imSize.width/2);
	rmin=0.2*((imSize.width>imSize.height)?imSize.height/2:imSize.width/2);
	lx=0.5*imSize.width;
	ly=0.5*imSize.height;
	int win_siz	= 7;
	int arr_siz	= NUMX*NUMY;
	CvPoint2D32f p0 = cvPoint2D32f(imSize.width/2,imSize.height/2);
	IplImage*	pyr = cvCreateImage(imSize,8,1);
	IplImage*	pyr_old = cvCreateImage(imSize,8,1);
	char* status	=0;
	status = (char*)cvAlloc(arr_siz);


	cvNamedWindow("testWindow");
	cvNamedWindow("ImgA");
	cvShowImage("ImgA", imgA);
	cvNamedWindow("ImgB");
	cvShowImage("ImgB", imgB);

	CvPoint2D32f*	arrg		= new CvPoint2D32f[arr_siz];
	CvPoint2D32f*	arrg_old	= new CvPoint2D32f[arr_siz];

	int counter=0;
	for(int x=0; x<NUMX; x++) {
		for(int y=0; y<NUMY; y++) {
			arrg_old[counter].x = p0.x + (-lx/2) + lx*x/NUMX;
			arrg_old[counter].y = p0.y + (-ly/2) + lx*y/NUMY;
			counter++;
		}
	}
	cout << "fuck-0" << endl;
	for(int i=0; i<arr_siz; i++) {
		cvLine(img,cvPointFrom32f(arrg_old[i]),cvPointFrom32f(arrg_old[i]),CV_RGB(0,0,0),4);
	}
	cvShowImage("testWindow",img);
	cvWaitKey(100);
	cout << "fuck-1" << endl;

	cvFindCornerSubPix(imgA,
	        			arrg_old,
	        			arr_siz,
	        			cvSize(win_siz,win_siz),
	        			cvSize(2,2),
	        			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03));
	//cvReleaseImage(&img);
	//img = cvLoadImage(imcd0,CV_LOAD_IMAGE_UNCHANGED);
	cout << "fuck-2" << endl;
	for(int i=0; i<arr_siz; i++) {
		cvLine(img,cvPointFrom32f(arrg_old[i]),cvPointFrom32f(arrg_old[i]),CV_RGB(255,0,255),4);
	}
	cvShowImage("testWindow",img);
	cvWaitKey(100);
	cout << "fuck-3" << endl;

	float errors[arr_siz];
	cvCalcOpticalFlowPyrLK(imgA,imgB,
	        			pyr_old, pyr,
	        			arrg_old,
	        			arrg,
	        			arr_siz,
	        			cvSize(win_siz,win_siz),
	        			5,
	        			status,
	        			errors,
	        			cvTermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.3),
	        			0);

	CvPoint2D32f dp, dp2;
	CvPoint2D32f center = cvPoint2D32f(0., 0.);
	bool arr_draw[arr_siz];
	int count = 0;
	for(int i=0; i<arr_siz; i++) {
		cvLine(img,cvPointFrom32f(arrg[i]),cvPointFrom32f(arrg[i]),CV_RGB(0,255,0),4);
		CvScalar color = CV_RGB(255,0,0);
		dp = getDp(arrg[i],arrg_old[i]);
		double len = getLength(dp);
//		if(errors[i]<50) {
		if(getLength(dp)>3) {
			color = CV_RGB(255,0,0);
		} else {
			color = CV_RGB(100,255,100);
		}
		int nc = i+1;
		arr_draw[i] = false;
		if((nc>-1) && (nc<arr_siz) && len>3) {
			dp2=getDp(arrg[nc],arrg_old[nc]);
			if(getLength(dp2)>2) {
				CvPoint2D32f ctmp = getCrossPoint(arrg_old[i],getOrtoVec(dp), arrg_old[nc],getOrtoVec(dp2));
//				cvLine(img,cvPointFrom32f(arrg_old[i]),cvPointFrom32f(ctmp),CV_RGB(0,0,0),1);
//				cvLine(img,cvPointFrom32f(arrg[i]),cvPointFrom32f(ctmp),CV_RGB(0,0,0),1);
				center = getSum(center,ctmp);
				count++;
				arr_draw[i] = true;
			}
		}
		drawArrow(img,arrg_old[i],arrg[i],color,2,15.);
		cout << "status=[" << (int)status[i] << "], error=[" << errors[i] << "]" << endl;
//		cout << "[" << arrg[i].x << "," << arrg[i].y << "]" << endl;

	}
	center=getDiv(center,count);

	cvCircle(img,cvPointFrom32f(center),10,CV_RGB(0,200,0),1);
	double df = 0;
	for(int i=0; i<arr_siz; i++) {
		if(arr_draw[i]) {
			cvLine(img, cvPointFrom32f(center), cvPointFrom32f(arrg_old[i]),CV_RGB(0,0,0),1);
			cvLine(img, cvPointFrom32f(center), cvPointFrom32f(arrg[i]),CV_RGB(0,0,0),1);
			df += 180.0*(getLength(getDel(arrg[i],arrg_old[i])))
			/(CV_PI*getLength(getDel(arrg_old[i],center)));
		}
	}
	CvFont font, fontbg;
	cvInitFont(&font,CV_FONT_HERSHEY_PLAIN, 2, 2, 0.0, 2, CV_AA);
	cvInitFont(&fontbg,CV_FONT_HERSHEY_PLAIN, 2, 2, 0.0, 8, CV_AA);
	char buff[100];
	bzero(buff,sizeof(buff));
	sprintf(buff,"angle=%0.1f degres",(df/count));
	cvPutText(img,buff,cvPoint(10,25),&fontbg,CV_RGB(0,0,0));
	cvPutText(img,buff,cvPoint(10,25),&font,CV_RGB(255,0,0));

/*
	for(int r=0; r<NUMR; r++) {
		for(int f=0; f<NUMF; f++) {
			double pfi = 2*CV_PI*f/NUMF;
			double ro	= rmin + (rmax-rmin)*r/NUMR;
			p1.x = p0.x + ro*cos(pfi);
			p1.y = p0.y + ro*sin(pfi);
			//cvLine(img,cvPointFrom32f(p1),cvPointFrom32f(p1),CV_RGB(0,0,255),2);
			drawArrow(img,p0,p1,CV_RGB(255,0,0));
		}
	}
*/
	cvShowImage("testWindow",img);
	cvWaitKey(0);

	cvDestroyWindow("testWindow");
	cvReleaseImage(&img);
	cout << "Shutdown" << endl;
	return 0;
}
