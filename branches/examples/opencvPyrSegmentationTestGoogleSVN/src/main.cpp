/*
 * main.cpp
 *
 *  Created on: 26.03.2009
 *      Author: ar
 */


#include <iostream>
//OpenCV
#include <cv.h>
#include <highgui.h>
#include "simplemath.h"
#include "smalllib.h"

#define NUMR	4
#define NUMF	18

const CvSize imSize = cvSize(800,600);
const static double rmax = 0.7*((imSize.width>imSize.height)?imSize.height/2:imSize.width/2);

int main( int argc, char* argv[] ) {

	IplImage* img = cvCreateImage(imSize,IPL_DEPTH_8U,3);
	cvNamedWindow("testWindow");
	double len_arrow = 0.5*((imSize.width>imSize.height)?imSize.height/2:imSize.width/2);
	CvPoint2D32f p0 = cvPoint2D32f(100,80);
	CvPoint2D32f a0 = cvPoint2D32f(10,0);
	drawArrow(img,p0,cvPoint2D32f(p0.x+a0.x,p0.y+a0.y),CV_RGB(255,0,0),1,5.);

	CvPoint2D32f p1 = cvPoint2D32f(400,300);
	CvPoint2D32f a1 = cvPoint2D32f(10,20);
	drawArrow(img,p1,cvPoint2D32f(p1.x+a1.x,p1.y+a1.y),CV_RGB(255,0,0),1,5.);
	CvPoint2D32f pc = getCrossPoint(p0,getOrtoVec(a0),p1,getOrtoVec(a1));
	if (pc.x<0) {
		cout << "Fuck, crosssection <0!" <<endl;
	} else {
		cvCircle(img,cvPointFrom32f(pc),10,CV_RGB(0,255,0),1);
		cvLine(img, cvPointFrom32f(pc), cvPointFrom32f(p0), CV_RGB(0,255,0), 1);
		cvLine(img, cvPointFrom32f(pc), cvPointFrom32f(p1), CV_RGB(0,255,0), 1);
	}

	cvShowImage("testWindow",img);

/*
	drawArrow(img,cvPoint2D32f(100,100),cvPoint2D32f(400,200),CV_RGB(255,0,0),2,1.);
	cvShowImage("testWindow",img);

	CvPoint2D32f p0 = cvPoint2D32f(imSize.width/2,imSize.height/2);
	double len_arrow = 0.5*((imSize.width>imSize.height)?imSize.height/2:imSize.width/2);
	CvPoint2D32f p1 = cvPoint2D32f(0,len_arrow);
	while(true) {
		cvFillImage(img,0);

		double df = CV_PI*dphi/180;
		p1 = cvPoint2D32f(
				p1.x*cos(df)+p1.y*sin(df),
				-p1.x*sin(df)+p1.y*cos(df)
				);

		drawArrow(img,p0,cvPoint2D32f(p0.x+p1.x,p0.y+p1.y),CV_RGB(255,0,0),1,1.);
		cvShowImage("testWindow",img);
		int key = cvWaitKey(40);
		if(key==27) break;
	}
	*/

	cvWaitKey(0);
	cvDestroyWindow("testWindow");
	cvReleaseImage(&img);
	cout << "Shutdown" << endl;
	return 0;
}
