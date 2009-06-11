/*
 * smalllib.h
 *
 *  Created on: 28.02.2009
 *      Author: ar
 */

#ifndef SMALLLIB_H_
#define SMALLLIB_H_

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

#include <cv.h>
#include <highgui.h>

/*
 *  some Error definitions
 */
#define ERROR_UNKNOWN			-1
#define ERROR_CREATE_CAPTURE	-2
#define ERROR_QUERY_FRAME		-3
#define ERROR_CR_VWRITER		-4

using namespace std;

/*
 * Convert AVI file to set of JPEG files
 */
//int convertAVItoJPEG(const string& file_avi, const string& dir_path);
int convertAVItoJPEG(const char* file_avi,const char* dir_path);

void drawCentrafBox(IplImage* img, CvPoint p1, CvPoint p2, CvScalar color, int lw);
void drawSquareBox(IplImage* img, CvPoint p, int l2, CvScalar color, int lw);

inline bool isEqualPoints(CvPoint p1, CvPoint p2) {
	return ((p1.x==p2.x) && (p1.y==p2.y));
}

inline double getModVel(CvPoint2D32f vel) {
	return sqrt(vel.x*vel.x + vel.y*vel.y);
}

inline CvPoint deltaPoints(CvPoint p0, CvPoint p1) {
	return cvPoint(p1.x-p0.x,p1.y-p0.y);
}

inline CvPoint2D32f deltaPoints2D32F(CvPoint2D32f p0, CvPoint2D32f p1) {
	return cvPoint2D32f(p1.x-p0.x,p1.y-p0.y);
}

CvPoint2D32f getVelocity(CvPoint2D32f* start, CvPoint2D32f* end, int len);
CvPoint2D32f getVelocityPPS(CvPoint2D32f* start, CvPoint2D32f* end, int len, double t0, double t1);

void drawVelocity(IplImage* img, CvPoint2D32f vel, CvPoint p0, int siz, CvScalar color, int thick);


int convertArrayFromIntTo2d32F(CvPoint* src, CvPoint2D32f* dst, int siz);
int convertArrayFrom2d32fToInt(CvPoint2D32f* src, CvPoint* dst, int siz);
int createPointArray(CvPoint* &array, CvPoint p0, CvPoint p1, CvSize gsize);
int createCopyArray(CvPoint* src, CvPoint* &dst, int num_elements);
int createCopyArray2D32F(CvPoint2D32f* src, CvPoint2D32f* &dst, int num_elements);
// safely free array of CvPoint (chek if arr is equal NULL)
void releasePointArray(CvPoint* &arr);
// safely free array of CvPoint2D32F (chek if arr is equal NULL)
void releasePointArray2D32F(CvPoint2D32f* &arr);
void drawPointsArray(IplImage* img, CvPoint* arr, int siz, CvScalar color);

#endif /* SMALLLIB_H_ */
